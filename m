Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34523 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750820AbdFOSfm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jun 2017 14:35:42 -0400
Received: by mail-io0-f181.google.com with SMTP id i7so17149202ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 Jun 2017 11:35:42 -0700 (PDT)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <D4ACE39C-B98F-4076-B9D1-9767CE76EFED@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_CE359BC9-E0E4-403E-A9F0-D94D7999EBD5";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
Date: Thu, 15 Jun 2017 12:35:29 -0600
In-Reply-To: <CAN-5tyEbqtP-=XmHRSKQbRrdPJgw3tmXzW-DmXwTvMLp7xR49w@mail.gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
To: Olga Kornievskaia <aglo@umich.edu>
References: <20170614170653.58083-1-kolga@netapp.com>
 <20170615081502.GA10599@infradead.org>
 <CAN-5tyEbqtP-=XmHRSKQbRrdPJgw3tmXzW-DmXwTvMLp7xR49w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_CE359BC9-E0E4-403E-A9F0-D94D7999EBD5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Jun 15, 2017, at 7:07 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Thu, Jun 15, 2017 at 4:15 AM, Christoph Hellwig <hch@infradead.org> =
wrote:
>> On Wed, Jun 14, 2017 at 01:06:53PM -0400, Olga Kornievskaia wrote:
>>> This is a proposal to allow 64bit count to copy and return as
>>> a result of a copy_file_range. No attempt was made to share code
>>> with the 32bit function because 32bit interface should probably
>>> get depreciated.
>>>=20
>>> Why use 64bit? Current uses of 32bit are by clone_file_range()
>>> which could use 64bit count and NFS copy_file_range also supports
>>> 64bit count value.
>>=20
>> Please provide a very good use case that actually matters to a large
>> portion of the Linux users.
>=20
> Reason: it will not hurt any user but it will help for
> server-to-server NFS copy because for each invocation of of
> copy_file_range() it requires that the client sends COPY_NOTIFY, then
> COPY and then a copy triggers a establishment of clientid/session
> before the reading of the source file can happen. All that could be
> saved by have a 64bit value.

What is the overhead of sending a couple of RPCs vs. copying 4GB of
data on the server?

> Current copy_file_range would work for any file size, it would just
> need to be called in a loop by the application. With the given
> proposal, there wouldn't be a need for the application to loop due to
> the API size limitation. It might still loop if a partial copy was
> done.


Given that there always needs to be a loop to handle partial completion,
adding the 64-bit syscall doesn't really simplify the application at
all, but adds duplicate code to the kernel for little benefit.

Cheers, Andreas






--Apple-Mail=_CE359BC9-E0E4-403E-A9F0-D94D7999EBD5
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZQtNzpIg59Q01vtYRAlzJAJwN/Eb1DW/aLn+rbuDD0canE6uVlACgnrFa
dv47OHSq2QEkwCGVG5TEOoY=
=8y7V
-----END PGP SIGNATURE-----

--Apple-Mail=_CE359BC9-E0E4-403E-A9F0-D94D7999EBD5--
