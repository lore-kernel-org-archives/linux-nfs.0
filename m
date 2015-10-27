Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34071 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbbJ0LfG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Oct 2015 07:35:06 -0400
Subject: Re: [PATCH v7 5/4] copy_file_range.2: New page documenting
 copy_file_range()
To: "J. Bruce Fields" <bfields@fieldses.org>,
        =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1445628736-13058-6-git-send-email-Anna.Schumaker@Netapp.com>
 <562B734D.50800@draigBrady.com> <20151026033925.GA9945@infradead.org>
 <562E1A55.4050409@draigBrady.com> <20151026214110.GA9232@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <562F613F.9070609@gmail.com>
Date: Tue, 27 Oct 2015 07:34:23 -0400
MIME-Version: 1.0
In-Reply-To: <20151026214110.GA9232@fieldses.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms030709020907030100010502"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms030709020907030100010502
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-10-26 17:41, J. Bruce Fields wrote:
> On Mon, Oct 26, 2015 at 12:19:33PM +0000, P=C3=A1draig Brady wrote:
>> I get the impression that you think reflinking should be hidden
>> from the user, i.e. cp(1) should not have had the --reflink option
>> (for the last 6 years)?  I'm not convinced of that, and even so
>> I think lower level interfaces would benefit from finer grained option=
s.
>> This would be especially useful since there is no general interface
>> to reflink at present. I was happy with the reflink control options,
>> thinking the extra control could allow cp to use this by default.
>
> Maybe that's a case for Christoph's "clone" operation.
>
> I agree with him that it makes sense to allow the filesystem to
> implement "copy" using reflink or similar tricks under the covers.  And=

> that in fact it's difficult to imagine how you'd prevent that in the
> presence of layers of filesystem or block protocols underneath.
>
> That "cp" flag seems strange to me, but if "cp" wants to take advantage=

> of a copy system call while continuing to make something like that
> distinction then I suppose it could fallocate the destination range fil=
e
> after the copy.
FWIW, I'm pretty sure that the '--reflink=3Dnever' option was added=20
originally just for those poor misguided people who don't understand=20
that deduplication is perfectly safe as long as you do it right.=20
Personally, I really hope that Busybox and the other Coreutils=20
replacements don't make that mistake, as the very fact that cp allows=20
you to force it not to reflink things indirectly implies that it isn't=20
safe in some circumstances, which is completely bogus WRT all the=20
filesystems in Linux that support it if they are used properly.

If you want to make sure the space is allocated on disk, you should be=20
using fallocate (or dd, or something equivalent), not cp.


--------------ms030709020907030100010502
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUxMDI3MTEzNDIzWjBPBgkq
hkiG9w0BCQQxQgRAMNghd9ydo4CtQqc+VMvXXAgozli2tiAc82q4T8ObvDcV39d4eMkYIUqN
M1Szne3Bx28Ck73o80KT04qEWy5cOjBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgA45h8rI2QLJ0BxC72pCkCIRjT9t42M59SIOTbPFXWzwZV9060D
PPgeoApmniTMhlQvqukeG+RvUgnFjvM+qwsGy6aypZZArFver03ylEv5IMZS62cFHesdqI1J
xvxGzr4S/Qqforb0jnQZy3PiMc9yRg0ekwdi5I5yXlRTlMHQlN5pIw1MuEpZC4UcHuzIMQuL
mRtIrl8ezpQuUSyOR6l9zf4vH4oOfbQ2L1/+e+NCSVlsoaiNVzynLs0RHrymz10J9xTGgrIH
KpGv+lwCDAMuII3yPzs0oSMp/EhVE5fxifJTO3xv+0G1sT1p3x5a4Uz5esLiLh4o16hCLuvV
EG5IcL9yuoWux9zPpE/C9JQKhfKBEVggfYYuHCWnYMtFnPyxO55kfu3vlO10exQgYrDNC0xe
8fkJsGUMQi/MgMF+WgtMc1qc8ws70/qglcwCS+8ILE/x7XLxR1Gtjl3rs685m5A3ehQvL7JA
SHiBMk7bxzpic46YN6zJxTWVQptNEs/x5JVvpO098ZCtPI93fDgkt/bY+2EKC0141avlGSko
HPB9+vlzC63tuB/sOHoZAZTpRD4tA4O+qom+LGs+SbOnTf6gvtx0pvhL+Kiz8NoxRPkM4aY2
iudQE+Um5sMdr7EGliFCUGFoMYbZd4KDEqFfAEXAuoUDWMqgFaI5lgak5wAAAAAAAA==
--------------ms030709020907030100010502--
