Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42262 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726753AbeJEEvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Oct 2018 00:51:12 -0400
From: NeilBrown <neilb@suse.com>
To: Jan Harkes <jaharkes@cs.cmu.edu>,
        David Howells <dhowells@redhat.com>
Date: Fri, 05 Oct 2018 07:55:39 +1000
Cc: dhowells@redhat.com, "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        linux-nfs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, coda@cs.cmu.edu,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] VFS: introduce MAY_ACT_AS_OWNER
In-Reply-To: <3D5BB0E9-E43C-43D1-86E9-96E409A17D54@cs.cmu.edu>
References: <153861496327.30373.10501882399296347125.stgit@noble> <153861471803.30373.6184444014227748848.stgit@noble> <28763.1538662213@warthog.procyon.org.uk> <3D5BB0E9-E43C-43D1-86E9-96E409A17D54@cs.cmu.edu>
Message-ID: <877eixtm04.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 04 2018, Jan Harkes wrote:

> Same for Coda.
>
> uid/gid/mode don't mean anything, access is based on the directory ACL an=
d the authentication token that is held by the userspace cache manager and =
ultimately decided by the servers.
>
> Unless someone broke this recently and made permission checks uid based I=
 would expect no change. If this is broken by a recent commit I expect some=
thing similar to what NFS is trying to do by allowing the actual check to b=
e passed down.

As with afs, the only permission check I can find that is uid based and
which actually affects coda is the check for use fcntl(F_SETFL) to set
O_NOATIME. I suspect that is irrelevant for coda.
I'll resubmit with the same code for both NFS and code - and probably
AFS.

Thanks,
NeilBrown


>
> Jan
>
> On October 4, 2018 10:10:13 AM EDT, David Howells <dhowells@redhat.com> w=
rote:
>>NeilBrown <neilb@suse.com> wrote:
>>
>>> diff --git a/fs/afs/security.c b/fs/afs/security.c
>>> index 81dfedb7879f..ac2e39de8bff 100644
>>> --- a/fs/afs/security.c
>>> +++ b/fs/afs/security.c
>>> @@ -349,6 +349,16 @@ int afs_permission(struct inode *inode, int
>>mask)
>>>  	if (mask & MAY_NOT_BLOCK)
>>>  		return -ECHILD;
>>>=20=20
>>> +	/* Short-circuit for owner */
>>> +	if (mask & MAY_ACT_AS_OWNER) {
>>> +		if (inode_owner_or_capable(inode))
>>
>>You don't know that inode->i_uid in meaningful.  You may have noticed
>>that
>>afs_permission() ignores i_uid and i_gid entirely.  It queries the
>>server (if
>>this information is not otherwise cached) to ask what permits the user
>>is
>>granted - where the user identity is defined by the key returned from
>>afs_request_key()[*].
>>
>>So, NAK for the afs piece.
>>
>>David
>>
>>[*] If there's no appropriate key, anonymous permits will be used.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlu2jFsACgkQOeye3VZi
gblLuRAAnR31Tb6JV0RE8ovKIvqI5QnUr0207Po+mbADvzWFLYoaZ8WolExNgVea
WSyDc0NcPWvtlnwcMWPpP++nznLSmYXk7bkFAgd+GWSth7GRIJHLmT8jGVmp7clg
Pufhm01ig/VRGpR/rrx+Wb+oDn5hlL1hs7kRQC1X8H378FuXBaeziCJzkhRCnruo
iWNjU/PKX0pBpCLcDQKZVyDoGec4fzw9R6T+2EPOrK1KRX+R0zrSeyBNLyytUhAa
rNiw42IRTvc7YMCekW0MInKWNaC5qhklWN61kQVrNkgBzJbob6tuE0kXO4HuisXQ
SijV6gwalEF5d08Zx+pxu5qKLMymK7E5CdAwgtf2Og3Bo6BZp+/MMtciuPmsNFKR
ec0MPohasRI1VFIvG3tV6axWif+axJ+wcJbGI3eJkNxDFussvStvXzZ9oc20mB9T
W212vQqiE5IdpHDmkSG1Dj8hQCFwNWtoA0waF/iVD1nI9XUi1LZoyrlN8+T/MSB0
C727iVI7tn5Z2YUOcr2yi+9guW+Gj4aNFEnNujQ7msVy6V2q+kQUwKcx4j3X4dB9
Tsaf4xjRs+WQb+q2DBqzp5ha4i6dDe8tLMKxdE1w1OSPTUfx7JEtBzqDePeVzfN6
fOqi6zUmTIU14ju/KGxyN3kDA17HSkTNCJ+Ufn3hUBjyzTb0i94=
=6336
-----END PGP SIGNATURE-----
--=-=-=--
