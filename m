From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [RFC][PATCH] nfs: don't assume fscache_acquire_cookie will always
 succeed
Date: Fri, 22 Jan 2010 18:22:53 +0530
Message-ID: <4B599FA5.5080103@suse.de>
References: <4B56F565.7080104@suse.de> <29178.1264072027@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: David Howells <dhowells@redhat.com>, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60456 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718Ab0AVMxF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 07:53:05 -0500
In-Reply-To: <29178.1264072027@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/21/2010 04:37 PM, David Howells wrote:
> Suresh Jayaraman <sjayaraman@suse.de> wrote:
> 
>> +	if (!clp->fscache)
>> +		goto error_cleanup;
> 
> This should be unnecessary.  FS-Cache's API functions in linux/fscache.h
> should handle a NULL cookie and do the right thing.
> 

Also, while poking around the code, noticed that nfs_clear_inode() calls
nfs_fscache_release_inode_cookie() which doesn't seem to check whether
"fsc" mount option (i.e. NFS_FSCACHE(inode)) was used or not and goes
ahead to call fscache_relinquish_cookie(). As I understand we should not
be calling any fscache related functions when the client doesn't use fsc
mount option (though CONFIG_NFS_FSCACHE is set), right?

Thanks,

-- 
Suresh Jayaraman
