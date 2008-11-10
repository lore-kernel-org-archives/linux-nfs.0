From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/9] rpc: call release_pipe only on last close
Date: Mon, 10 Nov 2008 16:18:03 -0500
Message-ID: <1226351883.7599.103.camel@heimdal.trondhjem.org>
References: <1226264683-28650-4-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-5-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-6-git-send-email-bfields@citi.umich.edu>
	 <1226344297.7599.41.camel@heimdal.trondhjem.org>
	 <20081110194900.GD19053@fieldses.org>
	 <1226347279.7599.47.camel@heimdal.trondhjem.org>
	 <20081110200727.GE19053@fieldses.org>
	 <1226347898.7599.49.camel@heimdal.trondhjem.org>
	 <20081110201708.GF19053@fieldses.org>
	 <1226348515.7599.52.camel@heimdal.trondhjem.org>
	 <20081110202640.GG19053@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30803 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973AbYKJVSq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 16:18:46 -0500
In-Reply-To: <20081110202640.GG19053@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-10 at 15:26 -0500, J. Bruce Fields wrote:
> Yep.  And when we're in that situation, last_close is true, so
> 
> 	if (last_close && ops->release_pipe)
> 		ops->release_pipe(inode)
> 
> does ensure that calls to the ->open_pipe() and ->release_pipe() methods
> balance, as originally claimed.
> 
> Maybe it'd be clearer to call that variable "still_open", or something?
> 
> 	still_open = rpci->nreaders != 0 || rpci->nwriters != 0;
> 	...
> 	if (still_open && ops->release_pipe)
> 		ops->release_pipe(inode)

Call it 'need_release'. It is definitely confusing right now...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
