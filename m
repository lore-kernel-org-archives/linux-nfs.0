Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:34216 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbbINOTW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 10:19:22 -0400
Received: by ykdg206 with SMTP id g206so153680948ykd.1
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 07:19:21 -0700 (PDT)
Date: Mon, 14 Sep 2015 10:19:18 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] fs: add fput_queue
Message-ID: <20150914101918.3d9c9235@tlielax.poochiereds.net>
In-Reply-To: <20150914141539.GS22011@ZenIV.linux.org.uk>
References: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
	<1442238355-8203-4-git-send-email-jeff.layton@primarydata.com>
	<20150914141539.GS22011@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 14 Sep 2015 15:15:39 +0100
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Sep 14, 2015 at 09:45:54AM -0400, Jeff Layton wrote:
> > +/**
> > + * fput_queue - do an fput without using task_work
> > + * @file: file of which to put the reference
> > + *
> > + * If we need to ensure that the final __fput is done on a file before
> > + * returning to userland, then we can't queue it to task_work. For that we
>                                                        ?????????
> > + * borrow the infrastructure used by kthreads, and the task can then just
> > + * called flush_delayed_fput to ensure that the final fput has completed.
> 
> Are you sure that it's not a typo?

I don't think so, but it could be clearer. Something like this maybe?

     "then we can't queue it via task_work_add."

-- 
Jeff Layton <jlayton@poochiereds.net>
