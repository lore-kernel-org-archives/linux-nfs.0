Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport2-out.teksavvy.com ([206.248.154.182]:50242 "EHLO
	ironport2-out.teksavvy.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757717Ab3APWvt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2013 17:51:49 -0500
Message-ID: <50F72F03.5070806@teksavvy.com>
Date: Wed, 16 Jan 2013 17:51:47 -0500
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org> <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com>
In-Reply-To: <50F63882.8000607@parallels.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13-01-16 12:20 AM, Stanislav Kinsbursky wrote:
> 
> Mark, could you provide any call traces?

Call traces from where/what?
There's this one, posted earlier in the BUG report:

kernel BUG at net/sunrpc/svc_xprt.c:921!
Call Trace:
 [<ffffffffa016a56a>] ? svc_recv+0xcc/0x338 [sunrpc]
 [<ffffffffa0318bfc>] ? nfs_callback_authenticate+0x20/0x20 [nfsv4]
 [<ffffffffa0318c19>] ? nfs4_callback_svc+0x1d/0x3c [nfsv4]
 [<ffffffff810407e6>] ? kthread+0x81/0x89
 [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
 [<ffffffff812ea62c>] ? ret_from_fork+0x7c/0xb0
 [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36

