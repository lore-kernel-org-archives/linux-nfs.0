From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc svc: be quieter
Date: Tue, 14 Mar 2006 16:29:19 -0500
Message-ID: <1142371759.7987.27.camel@lade.trondhjem.org>
References: <20060305005532.5E7A0870504@zog.reactivated.net>
	 <Pine.LNX.4.61.0603051451590.30115@yvahk01.tjqt.qr>
	 <1141678330.31680.13.camel@lade.trondhjem.org>
	 <441733C0.5040605@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	okir@monad.swb.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751888AbWCNVaD@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <441733C0.5040605@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2006-03-14 at 21:21 +0000, Daniel Drake wrote:
> Trond,
> 
> Trond Myklebust wrote:
> > They are probably trying to ping the server with a NULL procedure call
> > to test for service availability. We should allow that particular
> > usage...
> 
> Thanks, that sounds likely. Can you give some hints as to how a NULL 
> procedure call might appear? Would testing for prog==0 and/or proc==0 be 
> appropriate?

I can't see that authorising calls to prog==0 could ever be useful (what
would that mean?), but proc==0 is another matter: that is precisely the
NULL procedure call that I mentioned above.

Cheers,
  Trond
