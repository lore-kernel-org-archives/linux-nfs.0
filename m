Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44063 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753275AbdGGCmE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Jul 2017 22:42:04 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>, hch <hch@lst.de>
Date: Fri, 07 Jul 2017 12:41:54 +1000
Cc: "jlayton\@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna\@gmail.com" <schumaker.anna@gmail.com>
Subject: Re: open by handle support for NFS V2
In-Reply-To: <1498842056.6728.1.camel@primarydata.com>
References: <20170629133453.19641-1-hch@lst.de> <20170629154650.GC1651@fieldses.org> <1498842056.6728.1.camel@primarydata.com>
Message-ID: <87zichvuh9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 30 2017, Trond Myklebust wrote:

> On Thu, 2017-06-29 at 11:46 -0400, J. Bruce Fields wrote:
>> On Thu, Jun 29, 2017 at 06:34:49AM -0700, Christoph Hellwig wrote:
>> > this resurrects parts of an old series to add open by handle
>> > support to
>> > NFS.=C2=A0=C2=A0The prime intent here is to support the actual open by=
 handle
>> > ioctls, although it will also allow very crude re-
>> > exporting.=C2=A0=C2=A0Without
>> > the other patches from Jeff's series that re-exporting will suck
>> > badly
>> > though.
>>=20
>> Why do we want this?
>>=20
>> Any re-export support is going to have some major limitations.=C2=A0=C2=
=A0(No
>> file
>> locking, and re-export of NFSv4 probably not possible?)
>>=20
>> Last I heard the only motivation was extremely specific to Primary
>> Data's setup.=C2=A0=C2=A0I'm happy to help them, but I think we need *so=
me*
>> evidence this will be useful to upstream users.
>>=20
>
> The main use case for open by filehandle was (and still should be) the
> promise of being able to do the sort of tricks you normally associate
> with object storage on a standard filesystem.
>
> Imagine that you are trying to build an application for indexing and
> searching the data on your storage. You basically want to trawl through
> the filesystem on a regular basis and build up a database of key words
> and other metadata to tell you what is in the files. For that kind of
> application, the namespace is a real PITA to deal with, because files
> get renamed, moved and deleted all the time; so if you can store
> something that is independent of the namespace and that will give you
> access to the file contents, then why wouldn't you do so? Normally,
> applications like that use the inode number, but you can't open a file
> by inode number, and you have the same problems with inode number reuse
> that a NFS server has.
>
> That's the sort of thing I'd think we want to allow through open by
> filehandle, and I see no reason why NFS should be excluded from that
> type of application.

Given that the goal, and presumably the testing, is focused on this
use-case, I wonder if we should take steps to disable the NFS-re-export
use case.
As the patch stands, I suspect that NFS re-export would appear to work,
but - as Bruce suggests - would likely hit some problems.  This might
not be a user-friendly thing to do.

Probably the ideal would be to keep re-export disabled by default, but
to allow it to be enabled using a module parameter.
I'm not sure the best way for NFS to tell nfsd that export shouldn't be
trusted.
Maybe add a "flags" field to struct export_operations, which can contain
a "No NFS export" flag ??

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlle9PMACgkQOeye3VZi
gbmU2hAAqGyh6XufmUCiRWqSVKrbzmppOaZkTYkgR1WuWtlYxbFmk0DkK+O4uYP4
GOqT27qiGrkR1myTiTJ2drEy/C9CRKeL7Sy2X+W+wYA+RIxWHJWMzQ6uZ3lM5sH7
rwai0TdhEsn1OS77hRw0GVsqoVRxftjD/LJHvLVL1A/g6WwAhNoG28N0Cz3E9etY
vFGjhtvHnUce35ri3I86ga1rXGB+Gilu0rEdy3fXKg6Pe0MbLUTzgZYp01ji9V8n
ZcUSa949mBeDpIOk3K9osY62bmIj/i3U6Cu7dLDkZiQxEZD8g702UcBziZCYDPIX
A76VKmAX29F6QVlOOkW+hpo3M+Lvkn6dPumPJt6uC6Tjm5OQNwlWj5uyDp8/dTWF
S7kvWjqyWpJoockV7ZYmiY3C3gayzXStDLK+siE9o5CbriHuvhKo/kne4QvFM6pT
WRGNgUCVOmGPfFjzOpncERhy/FhNn/XrkCMBGG3RRcR1esU8VE3QUjsUJlR5fzRO
Xs/IdCq9CafdHGO9M/mKIgoDrVsOQOSt2PNP+kKUYD7hpJn3mMgtmC0D8a6qx5qi
zDQzFsb20O/Q21rPOmYilZLQ/GTYPv3lxubq4WPbTngHFm0wDI0PrLlDFA+tBz8P
J+oDyUoW0qxaaud5v8Hxk+2B+LzT2kKSm+T1HnGZeVO9CTy0Xpc=
=2gqk
-----END PGP SIGNATURE-----
--=-=-=--
