import Argo
import Result
import Runes

/// An access token is used for authorizing requests to the resource endpoint.
@objc
public class OAuthAccessToken: NSObject {
    /// The access token.
    public let accessToken: String

    /// The acess token's type (e.g., Bearer).
    public let tokenType: String

    /// The access token's expiration date.
    public let expiresAt: NSDate?

    /// The refresh token.
    public let refreshToken: String?

    /// Initializes a new access token.
    ///
    /// :param: accessToken The access token.
    /// :param: tokenType The access token's type.
    /// :param: expiresAt The access token's expiration date.
    /// :param: refreshToken The refresh token.
    ///
    /// :returns: A new access token initialized with access token, type,
    ///     expiration date and refresh token.
    public init(accessToken: String, tokenType: String, expiresAt: NSDate? = nil, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
    }

    /// Copies the access token, using new values if provided.
    ///
    /// :param: accessToken The new access token.
    /// :param: tokenType The new access token's type.
    /// :param: expiresAt The new access token's expiration date.
    /// :param: refreshToken The new refresh token.
    ///
    /// :returns: A new access token with this access token's values for
    ///     properties where new ones are not provided.
    public func copy(accessToken: String? = nil, tokenType: String? = nil, expiresAt: NSDate?? = nil, refreshToken: String?? = nil) -> OAuthAccessToken {
        return OAuthAccessToken(accessToken: accessToken ?? self.accessToken,
                                  tokenType: tokenType ?? self.tokenType,
                                  expiresAt: expiresAt ?? self.expiresAt,
                               refreshToken: refreshToken ?? self.refreshToken)
    }
}

extension OAuthAccessToken: Equatable {}

public func == (lhs: OAuthAccessToken, rhs: OAuthAccessToken) -> Bool {
    return lhs.accessToken == rhs.accessToken
        && lhs.tokenType == rhs.tokenType
        && lhs.expiresAt == rhs.expiresAt
        && lhs.refreshToken == rhs.refreshToken
}

extension OAuthAccessToken: Decodable {
    public class func create(accessToken: String)(tokenType: String)(expiresAt: NSDate?)(refreshToken: String?) -> OAuthAccessToken {
        return OAuthAccessToken(accessToken: accessToken, tokenType: tokenType, expiresAt: expiresAt, refreshToken: refreshToken)
    }

    public class func decode(json: JSON) -> Decoded<OAuthAccessToken> {
        func toNSDate(timeIntervalSinceNow: NSTimeInterval?) -> Decoded<NSDate?> {
            return .fromOptional(map(timeIntervalSinceNow) { timeIntervalSinceNow in
                return NSDate(timeIntervalSinceNow: timeIntervalSinceNow)
            })
        }

        return create
            <^> json <| "access_token"
            <*> json <| "token_type"
            <*> (json <|? "expires_in").flatMap(toNSDate)
            <*> json <|? "refresh_token"
    }

    public class func decode(data: NSData) -> Decoded<OAuthAccessToken> {
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
        return .fromOptional(flatMap(json, Argo.decode))
    }
}
