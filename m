From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 14:49:35 -0400
Message-ID: <1222454975.10150.8.camel@localhost>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net>
	 <20080925213831.GF14349@fieldses.org>
	 <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com>
	 <20080926184554.GA1492@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52204 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103AbYIZSuE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 14:50:04 -0400
In-Reply-To: <20080926184554.GA1492@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-09-26 at 14:45 -0400, J. Bruce Fields wrote:
> > If so, we could post it after 
> > the merge window closes.  It would give a little more time to do some 
> > testing.
> 
> That sound suspiciously like "since this is a high priority, it will be
> accepted later, so we can make it a lower priority."  Help!
> 
> But anyway, yes, we might have more time.

At the Kernel Summit Linus said he wants this kind of fix to go into the
merge window rather than in the -rc series if possible. His position was
that he'd rather revert a bad fix instead of delaying the testing in the
mainline kernel...

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
