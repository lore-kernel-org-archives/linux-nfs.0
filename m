Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41800 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726773AbeJEEr5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Oct 2018 00:47:57 -0400
From: NeilBrown <neilb@suse.com>
To: David Howells <dhowells@redhat.com>
Date: Fri, 05 Oct 2018 07:52:19 +1000
Cc: dhowells@redhat.com, "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Jan Harkes <jaharkes@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, coda@cs.cmu.edu,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] VFS: introduce MAY_ACT_AS_OWNER
In-Reply-To: <28763.1538662213@warthog.procyon.org.uk>
References: <153861496327.30373.10501882399296347125.stgit@noble> <153861471803.30373.6184444014227748848.stgit@noble> <28763.1538662213@warthog.procyon.org.uk>
Message-ID: <87a7nttm5o.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 04 2018, David Howells wrote:

> NeilBrown <neilb@suse.com> wrote:
>
>> diff --git a/fs/afs/security.c b/fs/afs/security.c
>> index 81dfedb7879f..ac2e39de8bff 100644
>> --- a/fs/afs/security.c
>> +++ b/fs/afs/security.c
>> @@ -349,6 +349,16 @@ int afs_permission(struct inode *inode, int mask)
>>  	if (mask & MAY_NOT_BLOCK)
>>  		return -ECHILD;
>>=20=20
>> +	/* Short-circuit for owner */
>> +	if (mask & MAY_ACT_AS_OWNER) {
>> +		if (inode_owner_or_capable(inode))
>
> You don't know that inode->i_uid in meaningful.  You may have noticed that
> afs_permission() ignores i_uid and i_gid entirely.  It queries the server=
 (if
> this information is not otherwise cached) to ask what permits the user is
> granted - where the user identity is defined by the key returned from
> afs_request_key()[*].
>
> So, NAK for the afs piece.

Thanks for the review.
As afs doesn't use the generic xattr code and doesn't call
setattr_prepare(), this is all largely irrelevant for afs.

afs_permission() will probably only get MAY_ACT_AS_OWNER passed when
someone uses fcntl(F_SETFL) to set the O_NOATIME flag.
Currently a permission test based on UID is performed which, as you say,
is wrong.  My patch simply preserved this current (wrong) behaviour.
Shall I change it to always allow access, like with NFS?
Probably O_NOATIME is ignored, in which case f_op->check_flags should
probably report -EINVAL (???) ... or might that cause a regression?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlu2i5QACgkQOeye3VZi
gbktMg/+OWLKA0/pjxbunAjnI0yn4NYbPgmQ9qFOBmgsH/z8ScYaU+ITYvbQ9EXD
QgNg2w87lj9pf2caztQRBl7nmFbpiHOHh+6pKJdKy32qziNxxQHwulo0n7nhsjCJ
Lx4Tr4rqQXDRY/y/gPZQyT2Vo0VkGg9AxQ9wwOWAT9j3ujEydCT1N/ED+qgezZdX
HEG2Fn3yFuo20qurR6ObRwaZnHXZJA22nZ9X9WCHBZxQgXTQBmq1Qlszg8aaKF3w
+0dAht+CYUEmjpKTx1UEMwkYR1ARLUnDqRvXovIlUGQjcGlAbv2c1YriOkOXDOz/
t0FWHkKDdSXHldl51fCJeLHjX58BGLiIB5Sq/o90yV0Fz9DVQcN0H5+OoLLM4qh2
lWD2aLd37tsPqsyisOxDxHiQd1E9eqr09+fiq15WDx4XUxtkZzl0FtkYPS3f4Xnd
h9sZFqfP8NpSmBaS1sfCKaQyjEmH0JE5GzGik7dXH9GPOiq6TF9Yey/LTLWUOrMr
znzzPdweIXANofG4PohccGdxI2MMP2vs/7ZxaslHq0raF+hG28pwdR78B1/Rl2F0
7GuXOgsB9aJV/b4h35x20pAOOQMcbtgiBwS7pk9j+k7BXFqAw0U+2cumZhMxE25n
wRQiQ2hSaTnlrgOuU8VCNoxbu2ExZvZRBqjRMnSp28BWjS/pjBo=
=33XB
-----END PGP SIGNATURE-----
--=-=-=--
