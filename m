From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] silence-call-timeout-printk
Date: Thu, 27 Mar 2008 16:53:11 -0400
Message-ID: <20080327205311.GL32540@fieldses.org>
References: <1206643752-11132-1-git-send-email-aglo@umich.edu> <20080327195445.GI32540@fieldses.org> <1206648229.15396.2.camel@heimdal.trondhjem.org> <20080327202331.GJ32540@fieldses.org> <EXNANE01kO22ZhCl8ai000001cd@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@umich.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59035 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756650AbYC0UxT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2008 16:53:19 -0400
In-Reply-To: <EXNANE01kO22ZhCl8ai000001cd-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 27, 2008 at 04:36:50PM -0400, Talpey, Thomas wrote:
> Let me get this straight. You are suggesting that bringing back
> cl_chatty as cl_quiet, in order to print messages when the
> server's callback client can't talk to the client's callback server,
> makes things clear? ;-)

Err, in order *not* to, actually.  (It's pretty easy for callbacks to
fail, especially the initial probe of the callback channel.  I don't
want to spam the server's logs about that.)

> 
> Oh, my head does hurt. :-) :-)

Yeah, OK ,fair enough.

> Seriously, it sounds okay but printk isn't exactly the best means
> for a server to tell people something doesn't work. The issue I see
> is that clients will lose a delegation, data corruption may result,

If the cb_path_down stuff is done conservatively enough, then in theory
there shouldn't be data corruption....

In any case, even if we think losing the callback path is worth a
printk, I still think that other cases (like failing to establish one in
the first case) aren't.

> and the only hint is a message in the server's log? Maybe I'm still
> having trouble with the first question.

So I'd rather we didn't put anything at all in the logs.  (Though
perhaps it could be useful to the administrator to have some optional
way to figure out the callback status if they were e.g. investigating a
performance problem.)

--b.
