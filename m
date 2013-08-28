Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.22]:57967 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224Ab3H1RVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Aug 2013 13:21:20 -0400
Received: from [92.224.47.239] ([92.224.47.239]) by mail.gmx.com (mrgmx003)
 with ESMTPSA (Nemesis) id 0MMBiP-1V7ImG3won-0082sF for
 <linux-nfs@vger.kernel.org>; Wed, 28 Aug 2013 19:21:19 +0200
Message-ID: <521E318C.7040401@gmx.de>
Date: Wed, 28 Aug 2013 19:21:16 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jan Kara <jack@suse.cz>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "user-mode-linux-devel@lists.sourceforge.net"
	<user-mode-linux-devel@lists.sourceforge.net>,
        linux-ext4@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: Issues with a rather unusual configured NFS server
References: <52075E01.7030506@gmx.de> <20130812143640.GF4596@quack.suse.cz> <20130813215313.GH17781@fieldses.org> <20130827180655.GE14809@fieldses.org>
In-Reply-To: <20130827180655.GE14809@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/27/2013 08:06 PM, J. Bruce Fields wrote:
> On Tue, Aug 13, 2013 at 05:53:14PM -0400, bfields wrote:
>> On Mon, Aug 12, 2013 at 04:36:40PM +0200, Jan Kara wrote:
>>> On Sun 11-08-13 11:48:49, Toralf Förster wrote:
>>>> so that the server either crashes (if it is a user mode linux image) or at least its reboot functionality got broken
>>>> - if the NFS server is hammered with scary NFS calls using a fuzzy tool running at a remote NFS client under a non-privileged user id.
>>>>
>>>> It can re reproduced, if
>>>> 	- the NFS share is an EXT3 or EXT4 directory
>>>> 	- and it is created at file located at tempfs and mounted via loop device
>>>> 	- and the NFS server is forced to umount the NFS share
>>>> 	- and the server forced to restart the NSF service afterwards
>>>> 	- and trinity is used
>>>>
>>>> I could find a scenario for an automated bisect. 2 times it brought this commit 
>>>> commit 68a3396178e6688ad7367202cdf0af8ed03c8727
>>>> Author: J. Bruce Fields <bfields@redhat.com>
>>>> Date:   Thu Mar 21 11:21:50 2013 -0400
>>>>
>>>>     nfsd4: shut down more of delegation earlier
>>
>> Thanks for the report.  I think I see the problem--after this commit
>> nfs4_set_delegation() failures result in nfs4_put_delegation being
>> called, but nfs4_put_delegation doesn't free the nfs4_file that has
>> already been set by alloc_init_deleg().
>>
>> Let me think about how to fix that....
> 
> Sorry for the slow response--can you check whether this fixes the
> problem?
> 
Yes.

With the attached patch the problem can't be reproduced any longer with
the prepared test case and current git kernels.

> --b.
> 
> commit 624a0ee0375940ce4aa36330b0b5a70af6d2b6f5
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Aug 15 16:55:26 2013 -0400
> 
>     nfsd4: fix leak of inode reference on delegation failure
>     
>     This fixes a regression from 68a3396178e6688ad7367202cdf0af8ed03c8727
>     "nfsd4: shut down more of delegation earlier".
>     
>     After that commit, nfs4_set_delegation() failures result in
>     nfs4_put_delegation being called, but nfs4_put_delegation doesn't free
>     the nfs4_file that has already been set by alloc_init_deleg().
>     
>     This can result in an oops on later unmounting the exported filesystem.
>     
>     Note also delaying the fi_had_conflict check we're able to return a
>     better error (hence give 4.1 clients a better idea why the delegation
>     failed; though note CONFLICT isn't an exact match here, as that's
>     supposed to indicate a current conflict, but all we know here is that
>     there was one recently).
>     
>     Reported-by: Toralf Förster <toralf.foerster@gmx.de>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index eb9cf81..0874998 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -368,11 +368,8 @@ static struct nfs4_delegation *
>  alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
>  {
>  	struct nfs4_delegation *dp;
> -	struct nfs4_file *fp = stp->st_file;
>  
>  	dprintk("NFSD alloc_init_deleg\n");
> -	if (fp->fi_had_conflict)
> -		return NULL;
>  	if (num_delegations > max_delegations)
>  		return NULL;
>  	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
> @@ -389,8 +386,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
>  	INIT_LIST_HEAD(&dp->dl_perfile);
>  	INIT_LIST_HEAD(&dp->dl_perclnt);
>  	INIT_LIST_HEAD(&dp->dl_recall_lru);
> -	get_nfs4_file(fp);
> -	dp->dl_file = fp;
> +	dp->dl_file = NULL;
>  	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
>  	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
>  	dp->dl_time = 0;
> @@ -3044,22 +3040,35 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
>  	return 0;
>  }
>  
> -static int nfs4_set_delegation(struct nfs4_delegation *dp)
> +static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
>  {
> -	struct nfs4_file *fp = dp->dl_file;
> +	int status;
>  
> -	if (!fp->fi_lease)
> -		return nfs4_setlease(dp);
> +	if (fp->fi_had_conflict)
> +		return -EAGAIN;
> +	get_nfs4_file(fp);
> +	dp->dl_file = fp;
> +	if (!fp->fi_lease) {
> +		status = nfs4_setlease(dp);
> +		if (status)
> +			goto out_free;
> +		return 0;
> +	}
>  	spin_lock(&recall_lock);
>  	if (fp->fi_had_conflict) {
>  		spin_unlock(&recall_lock);
> -		return -EAGAIN;
> +		status = -EAGAIN;
> +		goto out_free;
>  	}
>  	atomic_inc(&fp->fi_delegees);
>  	list_add(&dp->dl_perfile, &fp->fi_delegations);
>  	spin_unlock(&recall_lock);
>  	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
>  	return 0;
> +out_free:
> +	put_nfs4_file(fp);
> +	dp->dl_file = fp;
> +	return status;
>  }
>  
>  static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
> @@ -3134,7 +3143,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
>  	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
>  	if (dp == NULL)
>  		goto out_no_deleg;
> -	status = nfs4_set_delegation(dp);
> +	status = nfs4_set_delegation(dp, stp->st_file);
>  	if (status)
>  		goto out_free;
>  
> 


-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
