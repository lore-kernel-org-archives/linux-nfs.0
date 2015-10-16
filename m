Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33263 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbbJPOMM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 10:12:12 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Christoph Hellwig <hch@infradead.org>
References: <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org> <561EA83E.8080000@gmail.com>
 <20151015063621.GA3025@infradead.org> <561F9B13.7020804@gmail.com>
 <20151016053808.GA29510@infradead.org> <5620E3A1.90408@gmail.com>
 <20151016122151.GA5889@infradead.org> <5620F2A1.4060504@gmail.com>
 <20151016131250.GA15345@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <5621058B.1010704@gmail.com>
Date: Fri, 16 Oct 2015 10:11:23 -0400
MIME-Version: 1.0
In-Reply-To: <20151016131250.GA15345@infradead.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms000109040901070700070303"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms000109040901070700070303
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-10-16 09:12, Christoph Hellwig wrote:
> On Fri, Oct 16, 2015 at 08:50:41AM -0400, Austin S Hemmelgarn wrote:
>> Certain parts of userspace do try to reflink things instead of copying=
 (for
>> example, coreutils recently started doing so in mv and has had the opt=
ion to
>> do so with cp for a while now), but a properly designed general purpos=
e
>> filesystem does not and should not do this without the user telling it=
 to do
>> so.
>
> But they do.  Get out of your narrow local Linux file system view.
> Every all flash array or hyperconverge hypervisor will dedeup the hell
> out of your data, heck some SSDs even do it on the device.  Your NFS or=

> CIFS server already does or soon will do dedup and reflinks behind the
> scenes, that's the whole point of adding these features to the protocol=
=2E
Unless things have significantly changed on Windows and OS X, NTFS and=20
HFS+ do not do automatic data deduplication (I'm not sure whether either =

even supports reflinks, although NTFS is at least partly COW), and I=20
know for certain that FAT, UDF, Minix, BeFS, and Venti do not do so.=20
NFS and CIFS/SMB both have support in the protocol, but unless either=20
the client asks for it specifically, or the server is manually=20
configured to do it automatically (although current versions of Windows=20
server might do it by default, but if they do it is not documented=20
anywhere I've seen), they don't do it.  9P has no provisions for=20
reflinks/deduplication.  AFS/Coda/Ceph/Lustre/GFS2 might do=20
deduplication, but I'm pretty certain that they do not do so by default, =

and even then they really don't fit the 'general purpose' bit in my=20
statement above.  So, overall, my statement still holds for any widely=20
used filesystem technology that is actually 'general purpose'.

Furthermore, if you actually read my statement, you will notice that I=20
only said that _filesystems_ should not do it without being told to do=20
so, and (intentionally) said absolutely nothing about any kind of=20
storage devices or virtualization.  Ideally, SSD's really shouldn't do=20
it either unless they have a 100% guarantee that the entire block going=20
bad will not render the data unrecoverable (most do in fact use ECC=20
internally, but they typically only handle two or three bad bits out of=20
a full byte).  And as far as hypervisors go, a good storage hypervisor=20
should be providing some guarantee of reliability, which means either it =

is already storing multiple copies of _everything_ or using some form of =

erasure coding so that it can recover from issues with the underlying=20
storage devices without causing issues for higher levels, thus meaning=20
that deduplication in that context is safe for all intents and purposes.
> And except for the odd fear or COW or dedup, and the ENOSPC issue for
> which we have a flag with a very well defined meaning I've still not
> heard any good arguments against it.
Most people who I know who demonstrate this fear are just fine with COW, =

it's the deduplication that they're terrified of, and TBH that's largely =

because they've only ever seen it used in unsafe ways.  My main argument =

(which I admittedly have not really stated properly at all during this=20
discussion) is that almost everyone is likely to jump on this, which=20
_will_ change long established semantics in many things that switch to=20
this, and there will almost certainly be serious backlash from that.


--------------ms000109040901070700070303
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUxMDE2MTQxMTIzWjBPBgkq
hkiG9w0BCQQxQgRA2Z1XDo6cMhY+tCunosBimfhhE+YPuU3dvyZLccHt4NyN7M16T5IO2/+7
zARkZkPLqnImZzwgsea/zH+DXgGYgjBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgCIblrKPKHlpBZI+MeY37RUW2UWKatpVRmxUFWnZuGSbLfw7wcr
fEPIm1Y2OKZHgF7S3I96S7YGjeXM7nyXClNTGXM2DxSXE3PZPMYCVwHkNn3IDtfTEFK4lFoC
o563gTkDzO/JBe8N9GWKKv1mB2uaeTS9z2UojHQ+t8kkqAmMj0OFSLj+OylWhqECQYGhVayX
yi398019sXanzgWTBiY2JThbj4jBuyNoSl2aU2EOBjbN7wuuaJYIKvbEEyMtUmW7BImt3tgS
upjbfVYRas5lMQUbguIYNm/IBogOR5rulaM4td+JjhxL7qDLygqWML314gIGlDmXTk46Xmtt
VIR4ooB8QC4ZhecPrxbrQ8AVBsRFXTHWVvqfJo1Dx74UI5gVpTgN6d9G9d45kcMYj3AjamY1
rx0sldP+5H0NRPx0Xb8y/b1Xsxq3+WZskW0wPfg8UiVRdJv0jxb0K8qxEydNGzVniG8acM97
LxNyEWo0jfladnLYZ35Ue+j06XPt8D7yDtGpoyCh7qv3+Kaf0eMF6ppX2CnU1wyueLTOGfjI
I1DkfqSO54tVcOQOcwmphO7N+hrRB+ubt8KnviOBHiMucYNspOv9UKuYLo3SAxgwDg6hrjx5
KDn9d3Pd3Z/JJvVGmHUxVZ+ol3MN6r6PBG9CAlJfyYLaLssHDybPyMX24wAAAAAAAA==
--------------ms000109040901070700070303--
