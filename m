From: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] NFS: Revert default r/wsize behavior
Date: Wed, 30 Sep 2009 16:14:50 +0100
Message-ID: <4AC375EA.6080108@moving-picture.com>
References: <20090910205950.3670.7878.stgit@matisse.1015granger.net> <1252617432.8722.157.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:41536 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754480AbZI3POx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Sep 2009 11:14:53 -0400
In-Reply-To: <1252617432.8722.157.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> 
> Hmm.... Strictly speaking, I don't think we need to do this for the
> NFSv4 case, since that has no equivalent to the NFSv3 rtpref/wtpref
> attribute. It might help make the code look more consistent, though.
> 
> Note: at some point soon, I want to clean those functions up by
> introducing an 'alloc_nfs_parsed_mount_data()' function that both
> allocates the nfs_parsed_mount_data structure and initialises it with
> the common defaults.

I notice that 2.6.32-rc1 now has the 'alloc_nfs_parsed_mount_data()' 
function - but [rw]size still defaults to NFS_MAX_FILE_IO_SIZE - 
shouldn't these now be set to 0 by default?

Thanks

James Pearson






