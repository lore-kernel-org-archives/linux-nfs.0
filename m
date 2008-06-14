From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/5] rpc: add new gssd upcall pipe
Date: Sat, 14 Jun 2008 12:07:18 -0400
Message-ID: <1213459638.7149.16.camel@localhost>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-4-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-5-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-6-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7157 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752913AbYFNQHU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Jun 2008 12:07:20 -0400
In-Reply-To: <1213397442-15611-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-06-13 at 18:50 -0400, J. Bruce Fields wrote:
> This adds the new text-based gss upcall.  We only allow an open from
> either the new pipe or the old one, and use the pipe_open method to
> enforce this.
> 
> If no pipes are open, we provisionally queue messages for the new pipe;
> a subsequent open of the old pipe will cause all those messages to be
> purged.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---

I'm not happy about allowing the gss_auth layer to control timeouts and
cancel upcalls either: that caused us way too much grief and bugs in
earlier revisions of rpc_pipefs.

Why not rather disallow queueing (i.e. put the task to sleep, and maybe
print out a reminder on the console every minute or so) until you are
notified by the rpc_pipefs layer that someone has opened the file for
reading?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
