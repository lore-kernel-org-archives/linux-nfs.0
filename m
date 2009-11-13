From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: regression, bisected: getcwd() ENOENT on NFS4...
Date: Fri, 13 Nov 2009 21:59:46 +0900
Message-ID: <1258117186.7430.2.camel@heimdal.trondhjem.org>
References: <6278d2220910251631j40caec00lf2dee6159947d983@mail.gmail.com>
	 <1256563190.3742.4.camel@heimdal.trondhjem.org>
	 <6278d2220911010447v5889b9bbt33f685ef7669cc45@mail.gmail.com>
	 <6278d2220911040136m4cadc0f5sb71b8306bf02fc5b@mail.gmail.com>
	 <1257443105.3114.14.camel@heimdal.trondhjem.org>
	 <6278d2220911051641g5a626229o27dfc66faf588ca4@mail.gmail.com>
	 <6278d2220911130452u6e40662do44bcbcbaf9bad714@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45665 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684AbZKMM7q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Nov 2009 07:59:46 -0500
In-Reply-To: <6278d2220911130452u6e40662do44bcbcbaf9bad714-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-11-13 at 12:52 +0000, Daniel J Blueman wrote:
> Hi Trond,
> 
> On Fri, Nov 6, 2009 at 12:41 AM, Daniel J Blueman
> <daniel.blueman@gmail.com> wrote:
> > This fixes the behaviour and passes some heavy testing with two good
> > test-cases, with 2.6.32-rc6. As well, this would be good value for the
> > stable stream. I've sync'd the bugzilla report.
> 
> Is there opportunity to get this regression fix into 2.6.32-rc8, since
> -rc8 may be the (pen)ultimate before final?

It has been committed in the linux-next tree for testing for a few days
now. The plan is to send it on to Linus and stable@kernel.org in a
couple more days.

Cheers
  Trond

