From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] rpc: add new gssd upcall pipe
Date: Sun, 9 Nov 2008 15:46:50 -0500
Message-ID: <20081109204650.GE27376@fieldses.org>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu> <1213397442-15611-2-git-send-email-bfields@citi.umich.edu> <1213397442-15611-3-git-send-email-bfields@citi.umich.edu> <1213397442-15611-4-git-send-email-bfields@citi.umich.edu> <1213397442-15611-5-git-send-email-bfields@citi.umich.edu> <1213397442-15611-6-git-send-email-bfields@citi.umich.edu> <1213459638.7149.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52400 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755686AbYKIUqw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 15:46:52 -0500
In-Reply-To: <1213459638.7149.16.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 14, 2008 at 12:07:18PM -0400, Trond Myklebust wrote:
> On Fri, 2008-06-13 at 18:50 -0400, J. Bruce Fields wrote:
> > This adds the new text-based gss upcall.  We only allow an open from
> > either the new pipe or the old one, and use the pipe_open method to
> > enforce this.
> > 
> > If no pipes are open, we provisionally queue messages for the new pipe;
> > a subsequent open of the old pipe will cause all those messages to be
> > purged.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> 
> I'm not happy about allowing the gss_auth layer to control timeouts and
> cancel upcalls either: that caused us way too much grief and bugs in
> earlier revisions of rpc_pipefs.
> 
> Why not rather disallow queueing (i.e. put the task to sleep, and maybe
> print out a reminder on the console every minute or so) until you are
> notified by the rpc_pipefs layer that someone has opened the file for
> reading?

OK, done.

--b.
