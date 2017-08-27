Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36534 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751405AbdH0XZC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 27 Aug 2017 19:25:02 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>, Jeff Layton <jlayton@kernel.org>,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Date: Mon, 28 Aug 2017 09:24:43 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfs: track writeback errors with errseq_t
In-Reply-To: <1503683981.22608.0.camel@redhat.com>
References: <20170720194227.7830-1-jlayton@kernel.org> <1503683981.22608.0.camel@redhat.com>
Message-ID: <87h8wsiog4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 25 2017, Jeff Layton wrote:

> On Thu, 2017-07-20 at 15:42 -0400, Jeff Layton wrote:
>> From: Jeff Layton <jlayton@redhat.com>
>>=20
>> There is some ambiguity in nfs about how writeback errors are tracked.
>>=20
>> For instance, nfs_pageio_add_request calls mapping_set_error when the
>> add fails, but we track errors that occur after adding the request
>> with a dedicated int error in the open context.
>>=20
>> Now that we have better infrastructure for the vfs layer, this
>> latter int is now unnecessary. Just have nfs_context_set_write_error set
>> the error in the mapping when one occurs.
>>=20
>> Have NFS use file_write_and_wait_range to initiate and wait on writeback
>> of the data, and then check again after issuing the commit(s).
>>=20
>> With this, we also don't need to pay attention to the ERROR_WRITE
>> flag for reporting, and just clear it to indicate to subsequent
>> writers that they should try to go asynchronous again.
>>=20
>> In nfs_page_async_flush, sample the error before locking and joining
>> the requests, and check for errors since that point.
>>=20
>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>> ---
>>  fs/nfs/file.c          | 24 +++++++++++-------------
>>  fs/nfs/inode.c         |  3 +--
>>  fs/nfs/write.c         |  8 ++++++--
>>  include/linux/nfs_fs.h |  1 -
>>  4 files changed, 18 insertions(+), 18 deletions(-)
>>=20
>> I have a baling wire and duct tape solution for testing this with
>> xfstests (using iptables REJECT targets and soft mounts). This seems to
>> make nfs do the right thing.
>>=20
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index 5713eb32a45e..15d3c6faafd3 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -212,25 +212,23 @@ nfs_file_fsync_commit(struct file *file, loff_t st=
art, loff_t end, int datasync)
>>  {
>>  	struct nfs_open_context *ctx =3D nfs_file_open_context(file);
>>  	struct inode *inode =3D file_inode(file);
>> -	int have_error, do_resend, status;
>> -	int ret =3D 0;
>> +	int do_resend, status;
>> +	int ret;
>>=20=20
>>  	dprintk("NFS: fsync file(%pD2) datasync %d\n", file, datasync);
>>=20=20
>>  	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
>>  	do_resend =3D test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flag=
s);
>> -	have_error =3D test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags=
);
>> -	status =3D nfs_commit_inode(inode, FLUSH_SYNC);
>> -	have_error |=3D test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
>> -	if (have_error) {
>> -		ret =3D xchg(&ctx->error, 0);
>> -		if (ret)
>> -			goto out;
>> -	}
>> -	if (status < 0) {
>> +	clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
>> +	ret =3D nfs_commit_inode(inode, FLUSH_SYNC);
>> +
>> +	/* Recheck and advance after the commit */
>> +	status =3D file_check_and_advance_wb_err(file);

This change makes the code inconsistent with the comment above the
function, which still references ctx->error.  The intent of the comment
is still correct, but the details have changed.

Also, there is a call to mapping_set_error() in
nfs_pageio_add_request().
I wonder if that should be changed to
  nfs_context_set_write_error(req->wb_context, desc->pg_error)
??

Otherwise, patch looks good to me.
Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmjVL0ACgkQOeye3VZi
gblXpA//R5w0TjQRrI+W1OfhuaGOook7KoPpogpUWqElp/Ub2hs6geYIVEClB8SI
DqDXJ9PwHR9CE4SDzGQs/uEWx9xmVaC77JuAajaE1FE7CgHGjD5fLM4rIdU70yzW
FVuTCkFkE1Hc23Uy2Z2w0lpxt1r3JlX623pFlIYOp1d7l9boM5AAiLdRPnbaOVIs
rIyCeR5YkQOE1wSACQTeIcrUDJ0phCsAvxY7L0ru/fcnRR+Ju5ZCpmMaG23GD6Sg
jzfU9o5Yxbj650YNoOWO9i/0kotSaRMDbAJLAyo5g2oHg9+4wuu4jfZmqUrZkTjQ
iiK+f5nrdGgKHD4dH/KrJLjy536nCpi4XeSCzdRPvn4FxRWvMADCQaeubvqxQH/V
BjsVecaku+o1oQLg+klkrwPeBPhMg8MtNup+b8AJ/4ghvu7V48Ref3n+LeXnfaSY
wObUWUTgUOib0t9SvEXbaDzagRT0a2FaZLwKcG/j1x05aQVY7VoCstCU32fnpghg
ROXRZD4BLMhTxx6LiZv20tMP7d39CHee2b83J/pCgn0TL+F7u5yBqWz3JGsnrIoC
EZyhqIKjxBZlXg4isRhufB89tMypjx/eyxbymsnUYAkep9RdUcwtpc1uc/EJ08ZI
8t+FPEGHbSAB5vDFgG7WxbjUxe/dxPc43kODt3AVs4aVWXCRTfQ=
=TexK
-----END PGP SIGNATURE-----
--=-=-=--
