Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47473 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750749AbdGGE1p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Jul 2017 00:27:45 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>, hch <hch@lst.de>
Date: Fri, 07 Jul 2017 14:27:34 +1000
Cc: "jlayton\@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna\@gmail.com" <schumaker.anna@gmail.com>
Subject: Re: open by handle support for NFS V2
In-Reply-To: <1499397566.36826.1.camel@primarydata.com>
References: <20170629133453.19641-1-hch@lst.de> <20170629154650.GC1651@fieldses.org> <1498842056.6728.1.camel@primarydata.com> <87zichvuh9.fsf@notabene.neil.brown.name> <1499397566.36826.1.camel@primarydata.com>
Message-ID: <87r2xsx45l.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 07 2017, Trond Myklebust wrote:

> On Fri, 2017-07-07 at 12:41 +1000, NeilBrown wrote:
>> On Fri, Jun 30 2017, Trond Myklebust wrote:
>>=20
>> > On Thu, 2017-06-29 at 11:46 -0400, J. Bruce Fields wrote:
>> > > On Thu, Jun 29, 2017 at 06:34:49AM -0700, Christoph Hellwig
>> > > wrote:
>> > > > this resurrects parts of an old series to add open by handle
>> > > > support to
>> > > > NFS.=C2=A0=C2=A0The prime intent here is to support the actual ope=
n by
>> > > > handle
>> > > > ioctls, although it will also allow very crude re-
>> > > > exporting.=C2=A0=C2=A0Without
>> > > > the other patches from Jeff's series that re-exporting will
>> > > > suck
>> > > > badly
>> > > > though.
>> > >=20
>> > > Why do we want this?
>> > >=20
>> > > Any re-export support is going to have some major
>> > > limitations.=C2=A0=C2=A0(No
>> > > file
>> > > locking, and re-export of NFSv4 probably not possible?)
>> > >=20
>> > > Last I heard the only motivation was extremely specific to
>> > > Primary
>> > > Data's setup.=C2=A0=C2=A0I'm happy to help them, but I think we need=
 *some*
>> > > evidence this will be useful to upstream users.
>> > >=20
>> >=20
>> > The main use case for open by filehandle was (and still should be)
>> > the
>> > promise of being able to do the sort of tricks you normally
>> > associate
>> > with object storage on a standard filesystem.
>> >=20
>> > Imagine that you are trying to build an application for indexing
>> > and
>> > searching the data on your storage. You basically want to trawl
>> > through
>> > the filesystem on a regular basis and build up a database of key
>> > words
>> > and other metadata to tell you what is in the files. For that kind
>> > of
>> > application, the namespace is a real PITA to deal with, because
>> > files
>> > get renamed, moved and deleted all the time; so if you can store
>> > something that is independent of the namespace and that will give
>> > you
>> > access to the file contents, then why wouldn't you do so? Normally,
>> > applications like that use the inode number, but you can't open a
>> > file
>> > by inode number, and you have the same problems with inode number
>> > reuse
>> > that a NFS server has.
>> >=20
>> > That's the sort of thing I'd think we want to allow through open by
>> > filehandle, and I see no reason why NFS should be excluded from
>> > that
>> > type of application.
>>=20
>> Given that the goal, and presumably the testing, is focused on this
>> use-case, I wonder if we should take steps to disable the NFS-re-
>> export
>> use case.
>> As the patch stands, I suspect that NFS re-export would appear to
>> work,
>> but - as Bruce suggests - would likely hit some problems.=C2=A0=C2=A0Thi=
s might
>> not be a user-friendly thing to do.
>>=20
>> Probably the ideal would be to keep re-export disabled by default,
>> but
>> to allow it to be enabled using a module parameter.
>> I'm not sure the best way for NFS to tell nfsd that export shouldn't
>> be
>> trusted.
>> Maybe add a "flags" field to struct export_operations, which can
>> contain
>> a "No NFS export" flag ??
>>=20
>
> You could, but the reason why we developed the code in the first place,
> was because we have an internal use case which does involve re-export
> of NFS, so we're familiar with the limitations.
>
> FYI, the limitations are:
> 1) Recovery of locks is not possible when the re-exporting server is
> the one being rebooted. It works just fine for all other cases.
> 2) Re-exporting anything to NFSv2 is not possible.
> 3) Re-export of filesystems with very large filenandles could be
> problematic. This would also affect open-by-filehandle. In practice it
> turns out to be a non-issue because nobody uses filehandles > 64 bytes.
> 4) Stateless NFSv3 reads and writes can be a problem with NFSv4 when
> the application usees odd modebit settings such as 000.
>
> IOW: in practice this is no worse than all the other re-exporters such
> as already exist for gluster -> NFSv3, ceph -> NFSv3, NFS -> SMB,...
> and which everyone seems happy to use.
>

Thanks.  That isn't as bad as I feared.  Maybe it would be useful to put
notes like in this in the nfs(5) man page.
For the NFSv2 export I suspect that in some cases you might be
able to successfully mount, but then not access anything.
The linux NFS server uses a very small file handles for an export-point.
It might be good to have nfs_encode_fh always fail if *max_len <=3D 32/4
just to ensure that NFSv2 doesn't even get off the ground.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllfDbcACgkQOeye3VZi
gbm+yxAAmXGMC8Ych+6fux8MW3FAupeSP6HP8IPU8HWUA3JkYxWyinFLEZHC6Ico
Zjdtac1wa6g2aqdKgHwSGoPve1kHrx3S3poFf+wB74EudAuK9VNLLPAGjLmzlTt2
GynMU/cwuYhI2gHwoLONawC4otthZQgAythqB0N9++67ZgXsLmgxcyD8j7+BnSkU
RLvdHHhxAEYJY9N0CAtazULTnwyDzQ4v7Bess6vmBZ7Gbu6jW/X6zUwX1Im8uzLr
bGW2j6f1WiPwx5vkYj8X+Ivt/sVGTYK2S4oWRxfYGxDGBDIm85dbzMb24Zz78Bi4
okPuloz09DJyCtjtCXUcQr1jYC9lpFSn1wVQu7EAAiFUtRWNwaoNGjsO1ZDMTK/V
cBvsYgoPnDC4Lq0bwhUmBrrsDGMqQGaM8gwRpHAZT9o6JFfwMIdJVJgawASL3qN7
NFscrYr4VRZNbLtEDVfrMbA0kexioyAqfgdSgx4nXPqRaE3oe5gpZStPi5UNOPgL
exjqhsyy/84EmLCzmMykLmbqS5ozaw5RwFHaHy2NrZwrzfw6r17Ve9myMckhhy8U
bXqPbswln4gwwsKik/b96n51bVoQ8Umcuym+COlrDwC3Q+hGsRHE1vG2slRPqHf6
YsUBRr85YFPXjjKv7vAgyNP5VH9XnvsA25VL4gQD3nZdTAMYEoo=
=YApJ
-----END PGP SIGNATURE-----
--=-=-=--
