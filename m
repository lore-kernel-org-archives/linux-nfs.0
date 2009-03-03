From: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Subject: Re: kernel BUG at kernel/workqueue.c:291
Date: Tue, 03 Mar 2009 16:23:01 +0100
Message-ID: <49AD4B55.5060504@aei.mpg.de>
References: <49A84376.6030800@aei.mpg.de> <49ABBA44.1060302@aei.mpg.de>	 <20090302232643.7c7ca284.akpm@linux-foundation.org> <1236093413.9631.58.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:57509 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758044AbZCCPXS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 10:23:18 -0500
In-Reply-To: <1236093413.9631.58.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Trond Myklebust schrieb:
> struct rpc_task does admittedly share storage for the work queue and the
> rpc wait queue links, but if that were to be causing the reported
> corruption, then it would mean that an rpc_task is simultaneously on a
> wait queue and trying to execute on a work queue. I have no history of
> that ever having happened.

Anything I might be able to give to you helping you to narrow it down
somewhat? As written I suspect a certain type of user jobs, but since
literally 1000s of these ran over the course of several days it might be
hard to trigger this reliably again.

Cheers

Carsten
