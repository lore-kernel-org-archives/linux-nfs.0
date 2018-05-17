Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:37394 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751319AbeEQOPe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2018 10:15:34 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: Regression in [v2] nfs: Fix ugly referral attributes ?
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <19d4d696-3abc-42cd-28fb-86a24b572ddd@uni-mainz.de>
Date: Thu, 17 May 2018 10:15:06 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        898165-forwarded@bugs.debian.org, 898165@bugs.debian.org,
        ben@decadent.org.uk, Pradeep <pradeepthomas@gmail.com>
Message-Id: <832B58A4-C78E-44D4-AF79-31A619456106@oracle.com>
References: <20171105204404.10847.33767.stgit@manet.1015granger.net>
 <19d4d696-3abc-42cd-28fb-86a24b572ddd@uni-mainz.de>
To: Moritz Schlarb <schlarbm@uni-mainz.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 17, 2018, at 3:53 AM, Moritz Schlarb <schlarbm@uni-mainz.de> =
wrote:
>=20
> Hi everyone,
>=20
> there might be a regression coming from this patch:
> Since it got included in 3.16.54, our clients running a recent 3.16
> kernel (like from Debian jessie-security) did not follow NFS 4.1
> referrals (issued by nfs-ganesha) anymore.
> I have built that exact Debian kernel package with just this patch
> reversed and it worked again, so I got pretty confident that this =
patch
> is at least strongly related to the problem.
> Pradeep also confirmed the problem happening in 3.16.54 but not in =
3.16.51.
> Interestingly, this does *not* happen with 4.9 kernels, although the
> patch was part of 4.9.80...
>=20
> I have attached a pcap file of a machine running 3.16.56-1+deb8u1 in
> which I try to login as a user where my home directory is
> /uni-mainz.de/homes/schlarbm (with nfsrefer.zdv.uni-mainz.de:/ on
> /uni-mainz.de) which is then referred to
> fs02.uni-mainz.de:/vol/ma17/homes/schlarbm but that referral is not
> followed by the client.
>=20
> Please let me know if you need additional information to reproduce or
> have suggestions on what we could try.

Just a shot in the dark: Wondering if v3.16 needs

commit ea96d1ecbe4fcb1df487d99309d3157b4ff5fc02
Author:     Anna Schumaker <Anna.Schumaker@netapp.com>
AuthorDate: Fri Apr 3 14:35:59 2015 -0400
Commit:     Trond Myklebust <trond.myklebust@primarydata.com>
CommitDate: Thu Apr 23 14:43:54 2015 -0400

    nfs: Fetch MOUNTED_ON_FILEID when updating an inode


> Best regards,
> Moritz
>=20
> On 05.11.2017 21:45, Chuck Lever wrote:
>> Before traversing a referral and performing a mount, the mounted-on
>> directory looks strange:
>>=20
>> dr-xr-xr-x. 2 4294967294 4294967294 0 Dec 31  1969 dir.0
>>=20
>> nfs4_get_referral is wiping out any cached attributes with what was
>> returned via GETATTR(fs_locations), but the bit mask for that
>> operation does not request any file attributes.
>>=20
>> Retrieve owner and timestamp information so that the memcpy in
>> nfs4_get_referral fills in more attributes.
>>=20
>> Changes since v1:
>> - Don't request attributes that the client unconditionally replaces
>> - Request only MOUNTED_ON_FILEID or FILEID attribute, not both
>> - encode_fs_locations() doesn't use the third bitmask word
>>=20
>> Fixes: 6b97fd3da1ea ("NFSv4: Follow a referral")
>> Suggested-by: Pradeep Thomas <pradeepthomas@gmail.com>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Cc: stable@vger.kernel.org
>> ---
>> fs/nfs/nfs4proc.c |   18 ++++++++----------
>> 1 file changed, 8 insertions(+), 10 deletions(-)
>>=20
>> I could send this as an incremental, but that just seems to piss
>> off distributors, who will just squash them all together anyway.
>>=20
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 6c61e2b..2662879 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -254,15 +254,12 @@ static int nfs4_map_errors(int err)
>> };
>>=20
>> const u32 nfs4_fs_locations_bitmap[3] =3D {
>> -	FATTR4_WORD0_TYPE
>> -	| FATTR4_WORD0_CHANGE
>> +	FATTR4_WORD0_CHANGE
>> 	| FATTR4_WORD0_SIZE
>> 	| FATTR4_WORD0_FSID
>> 	| FATTR4_WORD0_FILEID
>> 	| FATTR4_WORD0_FS_LOCATIONS,
>> -	FATTR4_WORD1_MODE
>> -	| FATTR4_WORD1_NUMLINKS
>> -	| FATTR4_WORD1_OWNER
>> +	FATTR4_WORD1_OWNER
>> 	| FATTR4_WORD1_OWNER_GROUP
>> 	| FATTR4_WORD1_RAWDEV
>> 	| FATTR4_WORD1_SPACE_USED
>> @@ -6763,9 +6760,7 @@ static int _nfs4_proc_fs_locations(struct =
rpc_clnt *client, struct inode *dir,
>> 				   struct page *page)
>> {
>> 	struct nfs_server *server =3D NFS_SERVER(dir);
>> -	u32 bitmask[3] =3D {
>> -		[0] =3D FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
>> -	};
>> +	u32 bitmask[3];
>> 	struct nfs4_fs_locations_arg args =3D {
>> 		.dir_fh =3D NFS_FH(dir),
>> 		.name =3D name,
>> @@ -6784,12 +6779,15 @@ static int _nfs4_proc_fs_locations(struct =
rpc_clnt *client, struct inode *dir,
>>=20
>> 	dprintk("%s: start\n", __func__);
>>=20
>> +	bitmask[0] =3D nfs4_fattr_bitmap[0] | FATTR4_WORD0_FS_LOCATIONS;
>> +	bitmask[1] =3D nfs4_fattr_bitmap[1];
>> +
>> 	/* Ask for the fileid of the absent filesystem if =
mounted_on_fileid
>> 	 * is not supported */
>> 	if (NFS_SERVER(dir)->attr_bitmask[1] & =
FATTR4_WORD1_MOUNTED_ON_FILEID)
>> -		bitmask[1] |=3D FATTR4_WORD1_MOUNTED_ON_FILEID;
>> +		bitmask[0] &=3D ~FATTR4_WORD0_FILEID;
>> 	else
>> -		bitmask[0] |=3D FATTR4_WORD0_FILEID;
>> +		bitmask[1] &=3D ~FATTR4_WORD1_MOUNTED_ON_FILEID;
>>=20
>> 	nfs_fattr_init(&fs_locations->fattr);
>> 	fs_locations->server =3D server;
>>=20
> <nfs-referral-broken.pcap><schlarbm.vcf>

--
Chuck Lever



