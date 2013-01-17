Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55472 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753867Ab3AQNDh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jan 2013 08:03:37 -0500
Date: Thu, 17 Jan 2013 08:03:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Mark Lord <kernel@teksavvy.com>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
Message-ID: <20130117130335.GD6598@fieldses.org>
References: <50F42F85.50907@teksavvy.com>
 <20130114203711.GA29982@fieldses.org>
 <50F4D800.5040703@teksavvy.com>
 <20130115205625.GH4940@fieldses.org>
 <50F63882.8000607@parallels.com>
 <50F72F03.5070806@teksavvy.com>
 <50F786AF.4070107@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50F786AF.4070107@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 17, 2013 at 09:05:51AM +0400, Stanislav Kinsbursky wrote:
> 17.01.2013 02:51, Mark Lord пишет:
> >On 13-01-16 12:20 AM, Stanislav Kinsbursky wrote:
> >>
> >>Mark, could you provide any call traces?
> >
> >Call traces from where/what?
> >There's this one, posted earlier in the BUG report:
> >
> >kernel BUG at net/sunrpc/svc_xprt.c:921!
> >Call Trace:
> >  [<ffffffffa016a56a>] ? svc_recv+0xcc/0x338 [sunrpc]
> >  [<ffffffffa0318bfc>] ? nfs_callback_authenticate+0x20/0x20 [nfsv4]
> >  [<ffffffffa0318c19>] ? nfs4_callback_svc+0x1d/0x3c [nfsv4]
> >  [<ffffffff810407e6>] ? kthread+0x81/0x89
> >  [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
> >  [<ffffffff812ea62c>] ? ret_from_fork+0x7c/0xb0
> >  [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
> >
> 
> Thanks!
> I haven't seen the bug report.
> Could you provide the link, please?

There's no bz if that's what you're asking for.

See the first message in the thread for the original report:

	http://mid.gmane.org/<50F42F85.50907@teksavvy.com>

--b.
