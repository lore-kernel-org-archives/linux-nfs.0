Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport2-out.teksavvy.com ([206.248.154.182]:11179 "EHLO
	ironport2-out.teksavvy.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757773Ab3APW6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2013 17:58:04 -0500
Message-ID: <50F7307A.4090808@teksavvy.com>
Date: Wed, 16 Jan 2013 17:58:02 -0500
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org> <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com>
In-Reply-To: <50F72F03.5070806@teksavvy.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13-01-16 05:51 PM, Mark Lord wrote:
> On 13-01-16 12:20 AM, Stanislav Kinsbursky wrote:
>>
>> Mark, could you provide any call traces?
> 
> Call traces from where/what?
> There's this one, posted earlier in the BUG report:
> 
> kernel BUG at net/sunrpc/svc_xprt.c:921!
> Call Trace:
>  [<ffffffffa016a56a>] ? svc_recv+0xcc/0x338 [sunrpc]
>  [<ffffffffa0318bfc>] ? nfs_callback_authenticate+0x20/0x20 [nfsv4]
>  [<ffffffffa0318c19>] ? nfs4_callback_svc+0x1d/0x3c [nfsv4]
>  [<ffffffff810407e6>] ? kthread+0x81/0x89
>  [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
>  [<ffffffff812ea62c>] ? ret_from_fork+0x7c/0xb0
>  [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
..

This might be of some interest.
Here are the first few lines of the same BUG occurance,
with timestamps and the dmesg lines that immediately preceeded it.
Perhaps they might help indicate who's triggering the action
that results in the BUG(?).

Jan 14 10:58:05 zippy kernel: [66045.627952] NFS: Registering the id_resolver key type
Jan 14 10:58:05 zippy kernel: [66045.628014] Key type id_resolver registered
Jan 14 10:58:05 zippy kernel: [66045.628020] Key type id_legacy registered
Jan 14 10:58:05 zippy kernel: [66045.636302] ------------[ cut here ]------------
Jan 14 10:58:05 zippy kernel: [66045.648342] kernel BUG at net/sunrpc/svc_xprt.c:921!

