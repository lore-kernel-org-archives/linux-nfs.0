From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sunrpc svc: be quieter
Date: Wed, 19 Apr 2006 12:14:51 +0100
Message-ID: <44461BAB.9080301@gentoo.org>
References: <20060305005532.5E7A0870504@zog.reactivated.net>	 <Pine.LNX.4.61.0603051451590.30115@yvahk01.tjqt.qr>	 <1141678330.31680.13.camel@lade.trondhjem.org>	 <441733C0.5040605@gentoo.org> <1142371759.7987.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	okir@monad.swb.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750861AbWDSLBN@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <1142371759.7987.27.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:
> I can't see that authorising calls to prog==0 could ever be useful (what
> would that mean?), but proc==0 is another matter: that is precisely the
> NULL procedure call that I mentioned above.

Just to let you know, I did cook up a patch but the user has gone 
unresponsive (it's an important production server so finding downtime is 
hard).

Here is the patch if you are interested: 
http://bugs.gentoo.org/attachment.cgi?id=82195&action=view

If/when he responds, I'll remove the 2nd hunk and submit the patch properly.

Thanks,
Daniel
