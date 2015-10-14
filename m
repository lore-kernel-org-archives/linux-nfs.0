Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33412 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932339AbbJNTJ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 15:09:28 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Christoph Hellwig <hch@infradead.org>,
        Andy Lutomirski <luto@amacapital.net>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org> <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <561EA83E.8080000@gmail.com>
Date: Wed, 14 Oct 2015 15:08:46 -0400
MIME-Version: 1.0
In-Reply-To: <20151014182701.GC31225@infradead.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms070805030004010606060103"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms070805030004010606060103
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-10-14 14:27, Christoph Hellwig wrote:
> On Wed, Oct 14, 2015 at 11:08:40AM -0700, Andy Lutomirski wrote:
>>> So what I'm hearing is that I should drop the reflink and dedup flags=
 and change this system call only perform a full copy (with preserving of=
 sparseness), correct?  I can make those changes, but only if everybody i=
s in agreement that it's the best way forward.
>>
>> I personally rather like the reflink option.  That thing is quite usef=
ul.
>
> reflink is very useful, probably more useful than the copy actually. Bu=
t it
> is different from a copy.  It should be a separate interface.
Whether or not reflink is different from a copy is entirely a matter of=20
who is looking at it.  For someone looking directly at the block device, =

or trying to manipulate the block layout of the filesystem it is=20
definitely not a copy.  For a database app that needs ACID transaction=20
semantics, it is definitely not a copy (although for that usage, it's=20
arguably significantly better than a copy).  From the point of view of a =

generic userspace app that didn't perform the copy operation however,=20
and for anyone looking at it after the fact without paying attention to=20
the block layout, a reflink _is_ for all intents and purposes=20
functionally equivalent to a copy of the reflinked data (assuming of=20
course that the filesystem implements it properly, and that the hardware =

behaves right).

I would not in fact be surprised if at least some SCSI devices that=20
implement the XCOPY command do so internally using a reflink (I have not =

personally read the standard, but even if it 'requires' a compliant=20
device to actually create a separate copy of the data, there will still=20
be some vendors who ignore this), and it is well known that some SSD's=20
do in-band data deduplication effectively reducing a traditional copy to =

a reflink at the firmware level.

I agree that we shouldn't try to make a reflink by default (less than=20
intelligent programmers won't read the docs completely, and will make=20
various stupid assumptions about how this is 'supposed' to work, making=20
the defaults less ambiguous is a good thing), but it makes sense (at=20
least, it does to me) to have the ability to say 'make this block of=20
data appear at this location as well, I don't care how you do it as long =

as they are functionally independent for userspace applications'.


--------------ms070805030004010606060103
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUxMDE0MTkwODQ2WjBPBgkq
hkiG9w0BCQQxQgRAJvWX9ui9In4cPoFrHScO/NP30WQblhrhQQahOTA+x9rly/RwYYFR66sC
t4iMgypVX04+w8xmkuGcCXssGtAGNDBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgCRmixHKCJ/6B2ca1pw3qBc3FMltwPQ38hpXNttSAso8jG1AGfC
mazy/y1yfuCzbXPdzmh2j51zf+rMoQ8gpvy1vH8baMC2G2zgxocaYIS96Meuci2JaedstQu7
oNSVti0fKqfOeVV2mqhD0U7cunlrWotK8jeheaG34eNQMxSJZzqwyfkwCubXnzMWmWahh018
K0rXb012bOQZQBMaVq4cms8zuuUHHT+9ABByXTgWpIuuG88MIJOMAiw8nJeatrlmoQlrhN6h
NubJ48btj9Y0jkPPBfmoSlg+60BesWmEp8hqRU2ITZqK/IcVi+GHb/0JMKIA/yrI5Hg85gul
iWEJrYug13IB/poQZ+TlsUMZhZu4LUsS+/8qinPT1u+7X1kiN8QNrqmv5paj1Qy6yta1TQdU
FPWJrFe7Hrr0Fpd6oPKByt8GZLaksghyWerPs7O+8dYw3N1C6fnsBW5GHSvorZAwDXLgEwfl
7b/P4cGmwj/CNR9aGoL3zAAGUjpmYhsOtz7IZVvyWqOsghga7mB++2Fip6/Huy0krvdAQ1zi
Oc+qmSjd90Jve57Y00LOTN2p39vXPmqa8lqSo0ksn3FUGf0Oogb/U69aIEj0LPgw/fgRGTEU
WCLLGmS6sTG2qfDBIqMDiKnso0GKw2rjt+XmDwatR5BWmKRmZ5eW9/dZ4gAAAAAAAA==
--------------ms070805030004010606060103--
