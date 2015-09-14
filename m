Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33334 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbbINRag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 13:30:36 -0400
Received: by ykft14 with SMTP id t14so8052434ykf.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 10:30:35 -0700 (PDT)
Date: Mon, 14 Sep 2015 13:30:30 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] fs: add fput_queue
Message-ID: <20150914133030.634ece28@synchrony.poochiereds.net>
In-Reply-To: <20150914163954.GT22011@ZenIV.linux.org.uk>
References: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
	<1442238355-8203-4-git-send-email-jeff.layton@primarydata.com>
	<20150914141539.GS22011@ZenIV.linux.org.uk>
	<20150914101918.3d9c9235@tlielax.poochiereds.net>
	<20150914163954.GT22011@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 14 Sep 2015 17:39:54 +0100
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Sep 14, 2015 at 10:19:18AM -0400, Jeff Layton wrote:
> > > > + * borrow the infrastructure used by kthreads, and the task can then just
> > > > + * called flush_delayed_fput to ensure that the final fput has completed.
> > > 
> > > Are you sure that it's not a typo?
> > 
> > I don't think so, but it could be clearer. Something like this maybe?
> > 
> >      "then we can't queue it via task_work_add."
> 
> Huh?
> 
> task_work_add() callbacks *will* run before we return to userland

Right, but only just before. We need it to run before we try to set the
lease in the context of a fcntl() call. How about this text instead
then? I'll fix up the patch if this sounds reasonable:

"When fput is called in the context of a userland process, it'll queue
the actual work (__fput()) to be done just before returning to userland. In
some cases however, we need to ensure that the __fput runs before that
point. There is no safe way to flush work that has been queued via
task_work_add however, so to do this we borrow the delayed_fput
infrastructure that kthreads use. The userland process can use
fput_queue() on one or more struct files and then call
flush_delayed_fput() to ensure that they are completely closed."

-- 
Jeff Layton <jlayton@poochiereds.net>
