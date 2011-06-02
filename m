Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31680 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723Ab1FBQP2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2011 12:15:28 -0400
Subject: Re: [PATCH 1/1] NFSv4.1 fs_locations compound request fileid
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <1307031254.9634.12.camel@lade.trondhjem.org>
Date: Thu, 2 Jun 2011 12:15:25 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <2E12BF92-B535-4FF1-9ABC-D8C1FE783A20@netapp.com>
References: <1307027840-3137-1-git-send-email-andros@netapp.com> <1307031254.9634.12.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 2, 2011, at 12:14 PM, Trond Myklebust wrote:

> On Thu, 2011-06-02 at 11:17 -0400, andros@netapp.com wrote: 
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Commit 28331a46d88459788c8fca72dbb0415cd7f514c9 "Ensure we request the
>> ordinary fileid when doing readdirplus"
>> changed the meaning of NFS_ATTR_FATTR_FILEID which used to be set when
>> FATTR4_WORD1_MOUNTED_ON_FILED was requested. Request FATTR4_WORD0_FILEID
>> in the nfs4_proc_fs_locations GETATTR so that nfs_fhget succeeds and
>> the referral is mounted.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c |    3 ++-
>> 1 files changed, 2 insertions(+), 1 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index d2c4b59..d99c5f8 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -4685,7 +4685,8 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
>> {
>> 	struct nfs_server *server = NFS_SERVER(dir);
>> 	u32 bitmask[2] = {
>> -		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
>> +		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS |
>> +		      FATTR4_WORD0_FILEID,
>> 		[1] = FATTR4_WORD1_MOUNTED_ON_FILEID,
>> 	};
>> 	struct nfs4_fs_locations_arg args = {
> 
> Nope. We can't do this...
> 
> The ordinary fileid is _not_ supposed to be supported for an absent
> filesystem. See RFC3530bis, section 7.3.1.
> 
> The correct thing to do here is rather to allow the nfs_fhget() to
> succeed with only a mounted_on_fileid if (and only if!)
> NFS_ATTR_FATTR_MOUNTPOINT or NFS_ATTR_FATTR_V4_REFERRAL are set.

Ahh. OK - WIll do.

-->Andy
> 
> Cheers
>  Trond
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

