From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc svc: be quieter
Date: Mon, 06 Mar 2006 15:52:10 -0500
Message-ID: <1141678330.31680.13.camel@lade.trondhjem.org>
References: <20060305005532.5E7A0870504@zog.reactivated.net>
	 <Pine.LNX.4.61.0603051451590.30115@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Drake <dsd@gentoo.org>, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	okir@monad.swb.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751652AbWCFUwN@vger.kernel.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
In-Reply-To: <Pine.LNX.4.61.0603051451590.30115@yvahk01.tjqt.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sun, 2006-03-05 at 14:52 +0100, Jan Engelhardt wrote:
> >
> >A Gentoo user at http://bugs.gentoo.org/124884 reports that the following
> >message appears in the logs over 650 times every day:
> >
> >	svc: unknown version (0)
> >
> Should not the clients be fixed?
> 

They are probably trying to ping the server with a NULL procedure call
to test for service availability. We should allow that particular
usage...

Cheers,
  Trond
