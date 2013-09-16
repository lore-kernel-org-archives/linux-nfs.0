Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f179.google.com ([209.85.214.179]:42775 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab3IQEms convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Sep 2013 00:42:48 -0400
Received: by mail-ob0-f179.google.com with SMTP id wn1so4598445obc.24
        for <linux-nfs@vger.kernel.org>; Mon, 16 Sep 2013 21:42:48 -0700 (PDT)
Date: Mon, 16 Sep 2013 14:44:53 -0500
From: Rob Landley <rob@landley.net>
Subject: Re: [RFC] extending splice for copy offloading
To: Eric Wong <normalperson@yhbt.net>
Cc: Zach Brown <zab@redhat.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
	<20130911211722.GA9725@dcvr.yhbt.net>
In-Reply-To: <20130911211722.GA9725@dcvr.yhbt.net> (from
	normalperson@yhbt.net on Wed Sep 11 16:17:23 2013)
Message-Id: <1379360693.1974.29@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/11/2013 04:17:23 PM, Eric Wong wrote:
> Zach Brown <zab@redhat.com> wrote:
> > Towards the end of that thread Eric Wong asked why we didn't just
> > extend splice.  I immediately replied with some dumb dismissive
> > answer.  Once I sat down and looked at it, though, it does make a
> > lot of sense.  So good job, Eric.  +10 Dummie points for me.
> 
> Thanks for revisiting that :>
> 
> > Some things to talk about:
> > - I really don't care about the naming here.  If you do, holler.
> 
> Exposing "DIRECT" to userspace now might confuse users into expecting
> O_DIRECT behavior.  I say this as an easily-confused user.
> 
> In the future, perhaps O_DIRECT behavior can become per-splice  
> (instead
> of just per-open) and can save SPLICE_F_DIRECT for that.
> 
> > - We might want different flags for file-to-file splicing and  
> acceleration
> > - We might want flags to require or forbid acceleration
> 
> > - We might want to provide all these flags to sendfile, too
> 
> Another syscall?  I prefer not.  Better to just maintain the sendfile
> API as-is for compatibility reasons and nudge users towards splice.
> 
> > Thoughts?  Objections?
> 
> I'll try to test/comment more in a week or two (not much time for
> computing until then).

Just a vague note that I've wanted to use splice implementing cp and  
patch and cat and so on in toybox, but couldn't because it needs a pipe.

So I'm quite interested in moves to lift this restriction...

Rob