Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33405 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbbJES7V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 14:59:21 -0400
Subject: Re: [PATCH v8 00/41] Richacls
To: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
 <20151004062313.GA20212@infradead.org>
 <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <5612C85C.2060407@gmail.com>
Date: Mon, 5 Oct 2015 14:58:36 -0400
MIME-Version: 1.0
In-Reply-To: <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms050700070409080907050306"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms050700070409080907050306
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-10-05 14:45, Andreas Gruenbacher wrote:
> On Sun, Oct 4, 2015 at 8:23 AM, Christoph Hellwig <hch@infradead.org> w=
rote:
>> On Mon, Sep 28, 2015 at 12:08:51AM +0200, Andreas Gruenbacher wrote:
>>> Hello,
>>>
>>> here's another update of the richacl patch queue.  At this stage, I w=
ould
>>> like to ask for final feedback so that the core and ext4 code (patche=
s
>>> 1-19) can be merged in the 4.4 merge window.  The nfsd and nfs code s=
hould
>>> then go through the respective maintainer trees.
>>
>> Now way in this form even if everyone agrees we should have these
>> bastard ACLs.  I certainly disagree.
>
> Well, thanks for having a look at the patches.
>
>> Ayway, back to the VFS <-> FS interface.  You still require tons of
>> boilderplate code in the filesystem which isn't required and we got ri=
d
>> of for Posix ACLs.  The filesystem should not look at the userspace
>> xattr format, please follow a model similar to ->get_acl and ->set_acl=

>> for Posix ACLs.
>
> I will repost a version that has this cleaned up.
>
>> After that the wire up should be so trivial that you can wire up btrfs=
,
>> xfs and f2fs as well, which is important to make the feature mergeable=
=2E
>
> Why would the patch queue become more mergeable by having support for
> more filesystems in it? The filesystem specific code really isn't all
> that interesting.
I think the point is that a new VFS feature that is easy to integrate in =

multiple filesystems should have support for those filesystems.  A=20
decade ago, just having ext* support would probably have been fine, but=20
these days, XFS, BTRFS, and F2FS are used just as much (if not more) on=20
production systems as ext4, and having support for them right from the=20
start would significantly help with adoption of richacls.
>
>> And honestly I tink adding even more overload to xattrs is a really ba=
d
>> idea and after 10 years of experience with that junk we really need to=

>> learn and make new overloads proper system calls.
>
> Thanks,
> Andreas
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



--------------ms050700070409080907050306
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUxMDA1MTg1ODM2WjBPBgkq
hkiG9w0BCQQxQgRAesuYQixHNcNvNKdEXAkMO0SrlzjgSRXvG+VKTTgispT+Ev+Nyp1afnTK
86sDysI/n1W26OfvL4H3kjWD5eK5/jBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgB0CuK5Ufn0kUaCg5wjD705x7B5YXl82chXah6zut6mINbpN/qa
jyzXOPmOIsTlHbJeIvz1q+wIN2wY0THC4CjY00diaydVusef6aD99q9T3mKO5DlKEvQMq7oP
NuB/0Oe7QOzqxIpT476y7scYmbVDZhu0lU6OoHHfC5RSIswaLLHhU+aoRWO6rPSFch2sxLTd
JlinTQv8M3/ktrYa5tcXX0vsEkyA/zx53+0/EbGSlGWJVR5Da3oSmJSgRXXv4/DmmCABtzi6
YNqOxhrUTwme2qHyFXjsTW8l5hWz+7FJLEsosVL8Xv9Nut4GvPuIEj1gqtp8HaBt05ryVjvI
TleZF5oW/5uJQlHDDtORgleSLCqihDj9WBwz6s4/YHYV4TOgO19XEhC8atGbSuWOj6Y07uFP
IbH5PvGooyUJX2OtckwBTYaokSaH9yyaDy7tF8iRiIEjf7Nk5/7J90K2G9VL9J9svCzrsTvY
uhIIhScmYFCtFuDqt3evIOuyrzPPGkldFnltRpQoNOiz+kJEDvbnuTJhZ4/tz2ZF4QDKXNUd
JHdppwyDu9/XTVzLokuwq5rGHo8DWZbx0Feafb4/UtmmSul3LMxdvmtUJlVp2S5U+2gcZDL+
DAnh2ouws5tdFWpiTj615oZ+usUKrWcpIb1XYsNpPgzSWnlCd5m9C6ynDwAAAAAAAA==
--------------ms050700070409080907050306--
