From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/6] NSM: Serialize SM_MON and SM_UNMON upcalls
Date: Wed, 3 Dec 2008 22:55:24 -0500
Message-ID: <20081204035524.GA27563@fieldses.org>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net> <20081201185812.10600.92501.stgit@ingres.1015granger.net> <20081203214142.GS16846@fieldses.org> <F8B221DF-53B9-4F2C-B547-C6F556436B74@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36158 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666AbYLDDz3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Dec 2008 22:55:29 -0500
In-Reply-To: <F8B221DF-53B9-4F2C-B547-C6F556436B74@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 03, 2008 at 07:38:07PM -0500, Chuck Lever wrote:
> It's cleared in nlm_host_rebooted(), and in nsm_unmonitor().
>
> The nlm_host_mutex already provides much the same serialization that is 
> added in this patch, and at least on the server, nlm_lookup_host() and 
> nlm_destroy_host() both run under the BKL.
>
> The problem (if there is one) is really in nlm_host_rebooted(), which  
> this patch does nothing about.
>
> Let's drop this one for now.  I think there is a way to get rpc.statd to 
> report duplicates instead of ignoring them as it does now.  We should get 
> an idea of how pervasive this problem really is.

OK, fair enough.

I think it's a good catch, though, and one other motivation is that
*someday* (after fixing a bunch of similar locking problems) it would be
convenient if lockd could be made multithreaded.  And if we haven't seen
this particular problem in practice, part of the reason may be that
lockd is single-threaded and entirely under the BKL.

--b.
