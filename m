Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:38042 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804Ab3AQFGH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 00:06:07 -0500
Message-ID: <50F786AF.4070107@parallels.com>
Date: Thu, 17 Jan 2013 09:05:51 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Mark Lord <kernel@teksavvy.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org> <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com>
In-Reply-To: <50F72F03.5070806@teksavvy.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

17.01.2013 02:51, Mark Lord пишет:
> On 13-01-16 12:20 AM, Stanislav Kinsbursky wrote:
>>
>> Mark, could you provide any call traces?
>
> Call traces from where/what?
> There's this one, posted earlier in the BUG report:
>
> kernel BUG at net/sunrpc/svc_xprt.c:921!
> Call Trace:
>   [<ffffffffa016a56a>] ? svc_recv+0xcc/0x338 [sunrpc]
>   [<ffffffffa0318bfc>] ? nfs_callback_authenticate+0x20/0x20 [nfsv4]
>   [<ffffffffa0318c19>] ? nfs4_callback_svc+0x1d/0x3c [nfsv4]
>   [<ffffffff810407e6>] ? kthread+0x81/0x89
>   [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
>   [<ffffffff812ea62c>] ? ret_from_fork+0x7c/0xb0
>   [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
>

Thanks!
I haven't seen the bug report.
Could you provide the link, please?

-- 
Best regards,
Stanislav Kinsbursky
