Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32544 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab3ACVdK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2013 16:33:10 -0500
Received: from vmwexceht04-prd.hq.netapp.com (vmwexceht04-prd.hq.netapp.com [10.106.77.34])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r03LX8P0013721
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jan 2013 13:33:09 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix access to suid/sgid executables
Date: Thu, 3 Jan 2013 21:33:07 +0000
Message-ID: <0EC8763B847DB24D9ADF5EBD9CD7B4191259FA59@SACEXCMBX02-PRD.hq.netapp.com>
References: <1357245193-10375-1-git-send-email-dros@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91198820D@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91198820D@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 3, 2013, at 3:47 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-01-03 at 15:33 -0500, Weston Andros Adamson wrote:
>> nfs_open_permission_mask() shouldn't check MAY_READ for suid/sgid files that
>> are opened with __FMODE_EXEC.
>> 
>> Also fix NFSv4 access-in-open path in a similar way -- openflags must be
>> used because fmode will not always have FMODE_EXEC set.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> 
>> This patch fixes https://bugzilla.kernel.org/show_bug.cgi?id=49101
>> 
>> The fix is not as obvious or clean as I'd like, so here is a little background:
>> 
>> Not checking MAY_READ when a S_ISUID or S_ISGID file has MAY_EXEC causes
>> suid/sgid executables to behave the same as on a local FS.
>> 
>> The second part is fixing open-in-access for NFSv4 - we want to do the same
>> thing as in nfs_open_permission_mask, but oddly enough fmode doesn't always
>> indicate that the file is being opened for execution.  Instead we have to
>> use the openflags for this.
>> 
>> Adding some debug prints show that the first exec of a suid/sgid
>> file will open with fmode containing FMODE_EXEC and FMODE_READ, but subsequent
>> execs will open with fmode containing FMODE_READ, but not FMODE_EXEC.
>> openflags always has __FMODE_EXEC set in these examples.
>> 
>> The first exec has these values in nfs4_opendata_access():
>> 
>> fmode = 0x21: contains read exec
>> openflags = 0x8020: contains exec
>> 
>> The second (and subsequent) execs have these values in nfs4_opendata_access():
>> 
>> fmode = 0x1: contains read
>> openflags = 0x8020: contains exec
>> 
>> -dros
>> 
>> fs/nfs/dir.c      |   12 +++++++++---
>> fs/nfs/nfs4proc.c |   13 +++++++++++--
>> 2 files changed, 20 insertions(+), 5 deletions(-)
>> 
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index 32e6c53..5141243 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -2149,7 +2149,7 @@ out:
>> 	return -EACCES;
>> }
>> 
>> -static int nfs_open_permission_mask(int openflags)
>> +static int nfs_open_permission_mask(struct inode *inode, int openflags)
>> {
>> 	int mask = 0;
>> 
>> @@ -2157,14 +2157,20 @@ static int nfs_open_permission_mask(int openflags)
>> 		mask |= MAY_READ;
>> 	if ((openflags & O_ACCMODE) != O_RDONLY)
>> 		mask |= MAY_WRITE;
>> -	if (openflags & __FMODE_EXEC)
>> +	if (openflags & __FMODE_EXEC) {
>> 		mask |= MAY_EXEC;
>> +		/* don't check MAY_READ for exec of suid/sgid */
>> +		if (inode->i_mode & (S_ISUID | S_ISGID))
>> +			mask &= ~MAY_READ;
> 
> Wait, this can't be right. Why does the presence of a suid/sgid flag
> make a difference here? Either way, if __FMODE_EXEC access is requested,
> then we should only need MAY_EXEC rights.

Great point. Reposting after tests finish.

-dros

> 
>> +	}
>> +
>> 	return mask;
>> }
>> 
>> int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
>> {
>> -	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
>> +	return nfs_do_access(inode, cred,
>> +		nfs_open_permission_mask(inode, openflags));
>> }
>> EXPORT_SYMBOL_GPL(nfs_may_open);
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 5d864fb..23cf1a8 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1626,7 +1626,8 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
>> 
>> static int nfs4_opendata_access(struct rpc_cred *cred,
>> 				struct nfs4_opendata *opendata,
>> -				struct nfs4_state *state, fmode_t fmode)
>> +				struct nfs4_state *state, fmode_t fmode,
>> +				int openflags)
>> {
>> 	struct nfs_access_entry cache;
>> 	u32 mask;
>> @@ -1644,6 +1645,14 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
>> 	if (fmode & FMODE_EXEC)
>> 		mask |= MAY_EXEC;
>> 
>> +	/* use openflags to check for exec of suid/sgid, because fmode won't
>> +	 * always have FMODE_EXEC set by VFS.
>> +	 * Also, don't check MAY_READ on a suid/sgid file being executed */
>> +	if ((openflags & __FMODE_EXEC) &&
>> +	    (state->inode->i_mode & (S_ISUID | S_ISGID))) {
>> +		mask = MAY_EXEC;
>> +	}
> 
> Ditto...
> 
>> +
>> 	cache.cred = cred;
>> 	cache.jiffies = jiffies;
>> 	nfs_access_set_mask(&cache, opendata->o_res.access_result);
>> @@ -1896,7 +1905,7 @@ static int _nfs4_do_open(struct inode *dir,
>> 	if (server->caps & NFS_CAP_POSIX_LOCK)
>> 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
>> 
>> -	status = nfs4_opendata_access(cred, opendata, state, fmode);
>> +	status = nfs4_opendata_access(cred, opendata, state, fmode, flags);
>> 	if (status != 0)
>> 		goto err_opendata_put;
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

