Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33279 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbJPMv3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 08:51:29 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Christoph Hellwig <hch@infradead.org>
References: <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org> <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org> <561EA83E.8080000@gmail.com>
 <20151015063621.GA3025@infradead.org> <561F9B13.7020804@gmail.com>
 <20151016053808.GA29510@infradead.org> <5620E3A1.90408@gmail.com>
 <20151016122151.GA5889@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <5620F2A1.4060504@gmail.com>
Date: Fri, 16 Oct 2015 08:50:41 -0400
MIME-Version: 1.0
In-Reply-To: <20151016122151.GA5889@infradead.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms070901030501030004030107"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms070901030501030004030107
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-10-16 08:21, Christoph Hellwig wrote:
> On Fri, Oct 16, 2015 at 07:46:41AM -0400, Austin S Hemmelgarn wrote:
>> I should have been specific, what I meant was that some people will as=
sume
>> that it actually creates a physical, on-disk byte-for-byte copy of the=
 data.
>> There are many people out there (and sadly I have to deal with some at=
 work)
>> who are absolutely terrified of the concept of data deduplication, and=
 will
>> likely refuse to use this syscall for _anything_ if it reflinks by def=
ault
>> on filesystems that support it.
>
> If they use a file system that supports COW or dedup they are toast
> already.  It's not the system call that does the 'dedup', it's the file=

> system or storage device, that's where they need to set their
> preferences.
BTRFS is COW and supports deduplication, it does _absolutely zero_=20
reflinking and/or deduplication unless you explicitly tell it to do so.=20
  Likewise, ZFS is COW and supports deduplication, it also does=20
_absolutely zero_ reflinking and/or deduplication unless you tell it to=20
(note that in-band deduplication is off by default on ZFS).  AFAIK, XFS=20
will not automatically reflink instead of copying either (and if it does =

decide to do it automatically, that will just be something else to add=20
to the list of why I will never use it on any of my systems). OCFS2=20
supports reflinks (although not many people know this, and I think it=20
implements them slightly differently from BTRFS/ZFS/XFS) and yet again,=20
does _absolutely zero_ reflinking unless you tell it to.  Based on this, =

it is in no way the filesystem that does the deduplication and=20
reflinking, it only handles the implementation and provides the option=20
to the user to do it.

Certain parts of userspace do try to reflink things instead of copying=20
(for example, coreutils recently started doing so in mv and has had the=20
option to do so with cp for a while now), but a properly designed=20
general purpose filesystem does not and should not do this without the=20
user telling it to do so.


--------------ms070901030501030004030107
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUxMDE2MTI1MDQxWjBPBgkq
hkiG9w0BCQQxQgRAkbpeoq5CPChKNVkCxDjYjgc7ZMs/8M7T7yxLzkAsXgdxnCE1MU9d1E6S
M4FLtstwhV1NE6SEymWsNzvZfWcv3jBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgAAtzqwvdGoZD06IGJtMFuoCgo/uhl6+ZAwEH/fTwmaZNPNXify
0Gxw8QcWe95N5SjxpHYR9B3Rx6bkEk5JiVr5UoV/d4SLju2o2vd/q3aJrCoTm7OL7CHXmxq0
N1N47IOCt/Hsm8du3QUki4Pqztf3dQdoRD6Unb0xBwMUH6SZ3XK20jE59De6UrdjwIbWH3wk
I2DweSeth66w6qE6Y4RTgcKUFUVNZVCX015Tgmgu3m0UFPNk9uSKRpnSstPTkdnQnxpXSzE9
RD5ozPTUw7Mpackda679/XrbnBPfidLd6TBagCwWUgZsJzH43bxli9PaE+23zxTZvN/J4R/0
iX6ruzvBXt5xR4wcIobd6HdtPsHA2BF/gNoc105nOBZjnep735iHqelMvv4MEmFN2qkQiUTK
97E3UjCBR/q955y0EUNMpaBl25iAuixe4pHEoyHjvfUCg9IFIFN6gXP7ucfndF/jNpl44Vi2
hjmuI7dItUUJhLww7pLON4j7fA7nxkCqH1z4hhxZtD8aOVjAKnfBAwYqA55ZWzUqR1jVAMwb
6v6ipLwUYGFex41KQDV2hS30Zv3Lgv7VDP2KOpNworEjZTepILQXJo+4uJQf9bA36vkYCjSg
H5I1E4lGdtQTzwBnwcZZFOcLqQf8cCJ66k9ifvlGhEnmlUbNLm95eipFMAAAAAAAAA==
--------------ms070901030501030004030107--
