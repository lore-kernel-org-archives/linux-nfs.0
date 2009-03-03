From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: kernel BUG at kernel/workqueue.c:291
Date: Tue, 3 Mar 2009 12:41:26 -0800
Message-ID: <20090303204125.GB28232@merfinllc.com>
References: <49A84376.6030800@aei.mpg.de> <49ABBA44.1060302@aei.mpg.de> <20090302232643.7c7ca284.akpm@linux-foundation.org> <1236093413.9631.58.camel@heimdal.trondhjem.org> <49AD4B55.5060504@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:33451 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753787AbZCCUl3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 15:41:29 -0500
In-Reply-To: <49AD4B55.5060504-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Carsten,

On Mar 03 04:23 PM, Carsten Aulbert wrote:
> > struct rpc_task does admittedly share storage for the work queue and the
> > rpc wait queue links, but if that were to be causing the reported
> > corruption, then it would mean that an rpc_task is simultaneously on a
> > wait queue and trying to execute on a work queue. I have no history of
> > that ever having happened.
> 
> Anything I might be able to give to you helping you to narrow it down
> somewhat? As written I suspect a certain type of user jobs, but since
> literally 1000s of these ran over the course of several days it might be
> hard to trigger this reliably again.

Out of curiosity, do you know (approximately) the last kernel you ran
which did not show the BUG?

i.e. we know 2.6.27.14 is bad, what was the last known good kernel?

Thanks!

				=a=


-- 
===================
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org
