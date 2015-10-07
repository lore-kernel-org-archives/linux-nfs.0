Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36678 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbbJGNVr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 09:21:47 -0400
Subject: Re: [PATCH v9 00/43] Richacls
To: James Morris <jmorris@namei.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
References: <1444073830-21854-1-git-send-email-agruenba@redhat.com>
 <20151006090746.GA27791@xo-6d-61-c0.localdomain>
 <CAHc6FU79km84DAg+-EHkwyBf3Wq-e5AhBYQ1eXdS8mDpmPR0ow@mail.gmail.com>
 <alpine.LRH.2.20.1510071832320.20498@namei.org>
Cc: Pavel Machek <pavel@ucw.cz>, Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <56151C50.9060902@gmail.com>
Date: Wed, 7 Oct 2015 09:21:20 -0400
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.20.1510071832320.20498@namei.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms010502000503060407040607"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms010502000503060407040607
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-10-07 03:33, James Morris wrote:
> On Tue, 6 Oct 2015, Andreas Gruenbacher wrote:
>
>> On Tue, Oct 6, 2015 at 11:07 AM, Pavel Machek <pavel@ucw.cz> wrote:
>>> Should there be file in Documentation/ explaining how this works?
>>
>> There are plenty of comments in the code and in the patch descriptions=

>> that describe how the code works. The user-space package has manual
>> pages that describe how to use richacls; this information would not be=

>> accessible to users when put in Documentation/. Also, some background
>> information is available on http://www.bestbits.at/richacl/.
>
> Are many distros planning on enabling this?  I gather RH is...
>
I think a better question is "Are many distros planning on supporting=20
this?".  Most distros probably won't enable this immediately, and many=20
other than the enterprise ones are likely to put the choice on the=20
system administrator.  I would expect that RHEL, OEL, and SLES (and by=20
extension, Fedora, CentOS, and OpenSuSE) are likely to enable it, and=20
Ubuntu might.  Gentoo will likely take the same approach as it does with =

xattrs and POSIX ACL's, namely that if you want them, you enable them=20
yourself.  I would expect Arch to have support (probably within a week=20
or two of this being merged), but not enable them by default, and I'd=20
expect a similar policy from Debian.


--------------ms010502000503060407040607
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUxMDA3MTMyMTIwWjBPBgkq
hkiG9w0BCQQxQgRAZMwPFArop+RtdZbH8HeSv/ChAM+f/wvd+wwlWNrmlvkvRfnmPvTEz25D
tUv4J+o+CfYiQdNTOFZGL4TWzt2V3zBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgAe93WST/tuOuVvQvkSYOjZTmsvVxAd2A+L7IK/vYpyeK2qwOaf
kpIile4ffv4BhTfRN/kmJK7+m7o/kkDsEejWKJNhtIUW9Ks7IpDUBzkn2KHl0gp4n0ZBmtTr
Sl5Cmvntoi//Lv1B8UsPulEDcviuzuSwKltx6x1BKaxIDL5Lxitbwwd1o/1KDOk5aTQ8DVq+
kEFPcbOqqBZV4c1v1hBtOW3bkxCNTh2kIA9mVq0rJjX/hsA+5XNSarAF6iSh3yox9qT1/yYB
oiwD7GWM4XTFfu+XsKNKTdvUHrpqwRVBG4/A4KpDV2IMc0sFPY2rilQJcfT+e164nIxPinDS
9Pe2+TrDezXbL8+vFAEjLnXpc/CYd38xMTdWA06HtCPLL/t6DVtmzhansP27B1nNJmrQLFzj
bGFOORDkaFExq4S8wl0vWRljIg4KjZSb+3tV9ThzJBAYSoaWomo2iZmhC93/yRzNlEpj+bVr
gys3HnFzCwyq6T8wLMZ04JzjR78Te/6sJ2a8P4O6fI/PimqQsg66WKlRDtQKxOtqLfP5+n/o
xKluApXBVhULUWbgaNY2ExsfGJrnXN+B+yNl6oJAN4IrZlUVd/oC3LUux7mGgOzTTle0fzkI
Sge95xjZtEBQo3MN4zY7MCYpZvgI4HI3kSKTza8yZWqFDfxn9fmub1DOuQAAAAAAAA==
--------------ms010502000503060407040607--
