From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH] Fix NLM reference count panic
Date: Fri, 04 Jan 2008 17:58:34 -0500
Message-ID: <477EBA1A.4060906@redhat.com>
References: <477EB7D1.9030303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533AbYADXBA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 18:01:00 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m04N10fp001529
	for <linux-nfs@vger.kernel.org>; Fri, 4 Jan 2008 18:01:00 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m04N10v2025934
	for <linux-nfs@vger.kernel.org>; Fri, 4 Jan 2008 18:01:00 -0500
Received: from [172.16.59.29] (wendyc-t.rdu.redhat.com [172.16.59.29])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id m04N0xvn018211
	for <linux-nfs@vger.kernel.org>; Fri, 4 Jan 2008 18:01:00 -0500
In-Reply-To: <477EB7D1.9030303@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Forgot the signed-off line .. here it is ...
Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
>
> ------------------------------------------------------------------------
>
> This fixes the incorrect fclose call inside nlm_traverse_files() where 
> a posix lock could still be held by NFS client. Problem was found in a
> kernel panic inside locks_remove_flock() (fs/locks.c:2034) as part of 
> the fclose call due to NFS-NLM locks still hanging on inode->i_flock list. 
>
> Also see: http://people.redhat.com/wcheng/Patches/NFS/NLM/001.txt
>
>  svcsubs.c |    3 +--
>  1 files changed, 1 insertion(+), 2 deletions(-)
>
> --- gfs2-nmw/fs/lockd/svcsubs.c	2007-04-10 11:59:09.000000000 -0400
> +++ linux/fs/lockd/svcsubs.c	2007-04-18 10:01:23.000000000 -0400
> @@ -250,8 +250,7 @@ nlm_traverse_files(struct nlm_host *host
>  			mutex_lock(&nlm_file_mutex);
>  			file->f_count--;
>  			/* No more references to this file. Let go of it. */
> -			if (list_empty(&file->f_blocks) && !file->f_locks
> -			 && !file->f_shares && !file->f_count) {
> +			if (!nlm_file_inuse(file)) {
>  				hlist_del(&file->f_list);
>  				nlmsvc_ops->fclose(file->f_file);
>  				kfree(file);
>   

