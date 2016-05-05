Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:56891 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879AbcEEAKD (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Wed, 4 May 2016 20:10:03 -0400
From: NeilBrown <nfbrown@novell.com>
To: Dave Chinner <david@fromorbit.com>, David Howells <dhowells@redhat.com>
Date: Thu, 05 May 2016 10:09:49 +1000
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
In-Reply-To: <20160504225601.GZ26977@dastard>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125743.23636.85219.stgit@warthog.procyon.org.uk> <20160504225601.GZ26977@dastard>
Message-ID: <87shxxbc1e.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, May 05 2016, Dave Chinner wrote:

> On Fri, Apr 29, 2016 at 01:57:43PM +0100, David Howells wrote:
>>  (4) File creation time (st_btime*), data version (st_version), inode
>>      generation number (st_gen).
>>=20
>>      These will be returned if available whether the caller asked for th=
em or
>>      not.  The corresponding bits in st_mask will be set or cleared as
>>      appropriate to indicate a valid value.
>
> IMO, exposing the inode generation number to anyone is a potential
> security problem because they are used in file handles.

"security through obscurity".  We have Kerberos working really nicely
for NFS these days.  Do we still care?

What if the generation number were only made available to "root"?  Would
that allay your concerns?
Would that still be useful?
We already have name_to_handle_at().  Exposing the generation number
could/should follow the same rules at that.  Or maybe the exposure of
each field should be guided by the filesystem, depending on (for
example) whether it is used to provide uniqueness to the filehandle.

>
>>      If the caller didn't ask for them, then they may be approximated.  =
For
>>      example, NFS won't waste any time updating them from the server, un=
less
>>      as a byproduct of updating something requested.
>
> I would suggest that exposing them from the NFS server is something
> we most definitely don't want to do because they are the only thing
> that keeps remote users from guessing filehandles with ease....

Given that the NFS protocol does not define a "generation number"
attribute, I think there is no risk for them being exposed from the NFS
server ... except implicitly within the filehandle of course.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXKo9OAAoJEDnsnt1WYoG50RYQAJYplUTXpB1CyXiAl2DQFt9B
Um+CypGo7g3lVpLlVhM3kOjNc8AGJ7dOpfPvb5v3ahzHLqCdic8RK/ZNbUIvxT6g
JhqokLVgrklt9Swn0rOSRQ1/xzM1kNcieGUCgue4jjgOI0TxcnjTcidWfoi3a/91
Q26QEGMyN6l149wNnq8IRc+Ehv22w30HpoBk2z0Wp4fnilsDU1LEsvf+TYd86YTj
jUoFkOGEynwfkntK61pdWP6Evkj0W6TqXxYKn6JewDD4E0Ybvd5KxVMmQ6gOwube
Wk+mrm5SqrKNWto1kv7exgPsXF1KUI4hnSe00YCL45d4Ys5C0eacv/sr8IQHj1rD
Ys0Kop6yepel24/+qRSOkACr9jtxe6/56QgZtzCqTTJQktREO9Gq6613mtPgFg8f
Eo2e0FQK3izMPwYMOLy+JAfnWI5wKLMevqC9UclNyFxQj1mux3VePk7ivDkgdehW
ziCxC2TAPvHrOPIXHRucFbfNKKsgEoWsA41Aya875HNGrkhkUnubvCFvX0JPabLE
9+5M4rQVuKM1o+Ukc4Py4OTBR10QDHMZDznPN8KyFTZ6wFf/ubSloXbuMdD1Wc2h
FKcqxAvzVZYbSpE0LDoSyM4an/gmwqLFidtLGSlyzynTEHvHL7WZLRKuP548KbBc
oV9szr0hHj2vRwypsoCK
=T1+R
-----END PGP SIGNATURE-----
--=-=-=--
