Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37449 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753046Ab2EWSlh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2012 14:41:37 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4NIfa7p002396
	for <linux-nfs@vger.kernel.org>; Wed, 23 May 2012 11:41:37 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSv4.1 add nfs_inode book keeping for mdsthreshold
Date: Wed, 23 May 2012 18:41:36 +0000
Message-ID: <21DBA0D7-7C19-4DEA-8571-583967C7B7A7@netapp.com>
References: <1337763757-1566-1-git-send-email-andros@netapp.com>
 <1337763757-1566-3-git-send-email-andros@netapp.com>
 <1337797196.12011.8.camel@lade.trondhjem.org>
In-Reply-To: <1337797196.12011.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 23, 2012, at 2:19 PM, Myklebust, Trond wrote:

> On Wed, 2012-05-23 at 05:02 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Keep track of the number of bytes read or written, including those queued
>> up to be flushed. For use by mdsthreshold i/o size hints.
>> 
>> No locking needed as this is used as hint information.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/file.c          |    8 ++++++--
>> fs/nfs/inode.c         |    2 ++
>> fs/nfs/pnfs.c          |    3 +++
>> include/linux/nfs_fs.h |    3 +++
>> 4 files changed, 14 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index 8eda8a6..c4cc096 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -203,8 +203,10 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
>> 	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
>> 	if (!result) {
>> 		result = generic_file_aio_read(iocb, iov, nr_segs, pos);
>> -		if (result > 0)
>> +		if (result > 0) {
>> +			NFS_I(inode)->read_io += result;
> 
> Should we perhaps rather do this from nfs_readpages(), nfs_readpage()
> and nfs_direct_read()?
> 
> If we do it here in nfs_file_read, we miss mmaped reads, O_DIRECT reads,
> as well as splice reads.

Well that's not good.

> We also count read cache hits where we don't
> have to actually access the server.

OK.

> 
>> 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
>> +		}
>> 	}
>> 	return result;
>> }
>> @@ -613,8 +615,10 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
>> 		if (err < 0)
>> 			result = err;
>> 	}
>> -	if (result > 0)
>> +	if (result > 0) {
>> +		NFS_I(inode)->write_io += written;
> 
> For the same reason, perhaps we should move this to
> nfs_direct_write_schedule_iovec(), and nfs_write_end().
> 
>> 		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
>> +	}
>> out:
>> 	return result;
>> 
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 889f7e5..a6f5fbb 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -323,6 +323,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
>> 		inode->i_gid = -2;
>> 		inode->i_blocks = 0;
>> 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
>> +		nfsi->write_io = 0;
>> +		nfsi->read_io = 0;
>> 
>> 		nfsi->read_cache_jiffies = fattr->time_start;
>> 		nfsi->attr_gencount = fattr->gencount;
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index cbcb6ae..6620606 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -395,6 +395,9 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
>> 	dprintk("%s:Begin lo %p\n", __func__, lo);
>> 
>> 	if (list_empty(&lo->plh_segs)) {
>> +		/* Reset MDS Threshold I/O counters */
>> +		NFS_I(lo->plh_inode)->write_io = 0;
>> +		NFS_I(lo->plh_inode)->read_io = 0;
>> 		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
>> 			put_layout_hdr_locked(lo);
>> 		return 0;
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index ca4a707..c6954ac 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -201,6 +201,9 @@ struct nfs_inode {
>> 
>> 	/* pNFS layout information */
>> 	struct pnfs_layout_hdr *layout;
>> +	/* how many bytes have been written/read and how many bytes queued up */
>> +	__u64 write_io;
>> +	__u64 read_io;
>> #endif /* CONFIG_NFS_V4*/
> 
> ^^^^ This doesn't look as if it will compile without CONFIG_NFS_V4.

I'll fix and resend. Thanks for the review :)

-->Andy

> 
>> #ifdef CONFIG_NFS_FSCACHE
>> 	struct fscache_cookie	*fscache;
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

