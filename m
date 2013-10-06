Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f53.google.com ([209.85.219.53]:54323 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab3JFImi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 04:42:38 -0400
Received: by mail-oa0-f53.google.com with SMTP id i7so5447922oag.12
        for <linux-nfs@vger.kernel.org>; Sun, 06 Oct 2013 01:42:38 -0700 (PDT)
Date: Sun, 06 Oct 2013 03:42:35 -0500
From: Rob Landley <rob@landley.net>
Subject: Re: [RFC] extending splice for copy offloading
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Zach Brown <zab@redhat.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
	<CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
	<20130925183828.GA30372@lenny.home.zabbo.net>
	<CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
	<20130925190620.GB30372@lenny.home.zabbo.net>
	<20130925195526.GA18971@fieldses.org>
	<20130925210742.GG30372@lenny.home.zabbo.net>
	<CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
	<20130926153359.GE704@fieldses.org>
	<CAJfpegsUchb0eX+Hi3rN5Ypje3Y-dgo=pxgM1Y3BQbHVp=1hSw@mail.gmail.com>
In-Reply-To: <CAJfpegsUchb0eX+Hi3rN5Ypje3Y-dgo=pxgM1Y3BQbHVp=1hSw@mail.gmail.com>
	(from miklos@szeredi.hu on Thu Sep 26 13:06:41 2013)
Message-Id: <1381048955.1974.171@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/26/2013 01:06:41 PM, Miklos Szeredi wrote:
> On Thu, Sep 26, 2013 at 5:34 PM, J. Bruce Fields  
> <bfields@fieldses.org> wrote:
> > On Thu, Sep 26, 2013 at 10:58:05AM +0200, Miklos Szeredi wrote:
> >> On Wed, Sep 25, 2013 at 11:07 PM, Zach Brown <zab@redhat.com>  
> wrote:
> >> >> A client-side copy will be slower, but I guess it does have the
> >> >> advantage that the application can track progress to some  
> degree, and
> >> >> abort it fairly quickly without leaving the file in a totally  
> undefined
> >> >> state--and both might be useful if the copy's not a simple  
> constant-time
> >> >> operation.
> >> >
> >> > I suppose, but can't the app achieve a nice middle ground by  
> copying the
> >> > file in smaller syscalls?  Avoid bulk data motion back to the  
> client,
> >> > but still get notification every, I dunno, few hundred meg?
> >>
> >> Yes.  And if "cp"  could just be switched from a read+write syscall
> >> pair to a single splice syscall using the same buffer size.
> >
> > Will the various magic fs-specific copy operations become  
> inefficient
> > when the range copied is too small?
> 
> We could treat spice-copy operations just like write operations (can
> be buffered, coalesced, synced).
> 
> But I'm not sure it's worth the effort; 99% of the use of this
> interface will be copying whole files.

My "patch" implementation (in busybox and toybox) hits a point where it  
wants to copy the rest of the file, once there are no more hunks to  
apply. This is not copying a whole file. A similar thing happens with  
tail when you use the +N syntax to skip start instead of end lines. I  
can see sed doing a similar thing when told to operate on line ranges...

Note sure your 99% holds up here.

Rob