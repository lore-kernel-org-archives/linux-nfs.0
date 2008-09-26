From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 15:11:30 -0400
Message-ID: <1222456290.10150.10.camel@localhost>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net>
	 <20080925213831.GF14349@fieldses.org>
	 <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com>
	 <20080926184554.GA1492@fieldses.org> <1222454975.10150.8.camel@localhost>
	 <EF58CFE4-3F4B-4985-9DEA-E61CC0DFC8EA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50691 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751784AbYIZTLd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 15:11:33 -0400
In-Reply-To: <EF58CFE4-3F4B-4985-9DEA-E61CC0DFC8EA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-09-26 at 15:04 -0400, Chuck Lever wrote:
> 
> So in light of Linus' stated position, it would be helpful for me (and  
> maybe others on the list) to have a good feel for when you guys are  
> planning to push your merge-window changes to Linus before each window  
> opens.
> 
> At the very least, since many of us do not follow LKML, would someone  
> commit to reflecting the LKML merge announcements to linux-nfs?  Or is  
> there a kernel announcements list we can follow (or that we can  
> subscribe linux-nfs to)?

There are no announcements. The merge window starts as soon as 2.6.27 is
released, and lasts for 2 weeks. There has been some talk about
shortening it to 1 week, but that hasn't been fully decided yet.

IOW: Assume as soon as you see the 2.6.27 announcement, that we're
preparing the merge.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
