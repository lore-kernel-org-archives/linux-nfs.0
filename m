From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/9] rpc: call release_pipe only on last close
Date: Mon, 10 Nov 2008 14:11:37 -0500
Message-ID: <1226344297.7599.41.camel@heimdal.trondhjem.org>
References: <20081109204621.GD27376@fieldses.org>
	 <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-3-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-4-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-5-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-6-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61507 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbYKJTMX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 14:12:23 -0500
In-Reply-To: <1226264683-28650-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2008-11-09 at 16:04 -0500, J. Bruce Fields wrote:
> I can't see any reason we particularly need to call this until the last
> gssd closes the pipe.

There's a very good reason: if we call rpc_close_pipes() then it is
because the kernel listener is shutting down. At that point, we want to
return EPIPE for all future read() or write() attempts by gssd.

> Also, this allows to guarantee that open_pipe and release_pipe are
> called strictly in pairs; open_pipe on the first open, release_pipe on
> the last close.  That'll make it very easy for the gss code to keep
> track of which pipes gssd is using.

...unless the gss code is no longer running.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
