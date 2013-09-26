Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134Ab3IZPeD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 11:34:03 -0400
Date: Thu, 26 Sep 2013 11:34:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Zach Brown <zab@redhat.com>, Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130926153359.GE704@fieldses.org>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
 <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
 <20130925183828.GA30372@lenny.home.zabbo.net>
 <CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
 <20130925190620.GB30372@lenny.home.zabbo.net>
 <20130925195526.GA18971@fieldses.org>
 <20130925210742.GG30372@lenny.home.zabbo.net>
 <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 10:58:05AM +0200, Miklos Szeredi wrote:
> On Wed, Sep 25, 2013 at 11:07 PM, Zach Brown <zab@redhat.com> wrote:
> >> A client-side copy will be slower, but I guess it does have the
> >> advantage that the application can track progress to some degree, and
> >> abort it fairly quickly without leaving the file in a totally undefined
> >> state--and both might be useful if the copy's not a simple constant-time
> >> operation.
> >
> > I suppose, but can't the app achieve a nice middle ground by copying the
> > file in smaller syscalls?  Avoid bulk data motion back to the client,
> > but still get notification every, I dunno, few hundred meg?
> 
> Yes.  And if "cp"  could just be switched from a read+write syscall
> pair to a single splice syscall using the same buffer size.

Will the various magic fs-specific copy operations become inefficient
when the range copied is too small?

(Totally naive question, as I have no idea how they really work.)

--b.

> And then
> the user would only notice that things got faster in case of server
> side copy.  No problems with long blocking times (at least not much
> worse than it was).
> 
> However "cp" doesn't do reflinking by default, it has a switch for
> that.  If we just want "cp" and the like to use splice without fearing
> side effects then by default we should try to be as close to
> read+write behavior as possible.  No?   That's what I'm really
> worrying about when you want to wire up splice to reflink by default.
> I do think there should be a flag for that.  And if on the block level
> some magic happens, so be it.  It's not the fs deverloper's worry any
> more ;)
> 
> Thanks,
> Miklos
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
