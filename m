Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32969 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750754AbcIBEAJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Sep 2016 00:00:09 -0400
Received: by mail-pa0-f47.google.com with SMTP id cy9so36271652pac.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Sep 2016 21:00:08 -0700 (PDT)
Date: Thu, 1 Sep 2016 23:59:56 -0400
From: Noah Misch <noah@leadboat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: EACCES race when opening just-created file
Message-ID: <20160902035956.GA3426167@tornado.leadboat.com>
References: <20160723201238.GA2134756@tornado.leadboat.com>
 <1469307057.2514.6.camel@redhat.com>
 <20160726030432.GA2215551@tornado.leadboat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20160726030432.GA2215551@tornado.leadboat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 25, 2016 at 11:04:32PM -0400, Noah Misch wrote:
> On Sat, Jul 23, 2016 at 04:50:57PM -0400, Jeff Layton wrote:
> > On Sat, 2016-07-23 at 16:12 -0400, Noah Misch wrote:
> > > With the Linux kernel as both NFS client and server, I'm seeing a race
> > > condition where open() can return EACCES for a just-created file.  Is this
> > > expected behavior?  POSIX implicitly allows it, but I failed to locate any
> > > discussion of it.  I have attached a test program; here, it witnesses the race
> > > for roughly a dozen of the 4096 files it creates (different files each time).
> 
> > This is due to a limitation of NFSv3 and NFSv4.0. When you do an
> > exclusive create, the atime and mtime get set to a particular set of
> > values (the verifier), and the client is expected to override those
> > values with a follow-on SETATTR call once it gets those values back.
> > This is to prevent problems during certain server reboot scenarios. 
> > 
> > The NFS server also sets the mode to 0000 during this time (since the
> > client can't even set the mode during the operation).
> 
> Interesting; that fully explains it.  Thanks.
> 
> > NFSv4.1 is less subject to this problem. You may want to try using that
> > and see if it's any better.
> 
> I will look into that.

Mounting with vers=4.1 eliminated the unwanted behavior.  Thanks for the tip.
