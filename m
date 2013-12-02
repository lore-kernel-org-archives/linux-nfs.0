Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:45834 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3LBP6K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 10:58:10 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so21468311ieb.32
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 07:58:10 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <529C982B.2030906@parallels.com>
Date: Mon, 2 Dec 2013 10:58:07 -0500
Cc: Christoph Hellwig <hch@infradead.org>,
        Viro Alexander <viro@ZenIV.linux.org.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Torvalds Linus <torvalds@linux-foundation.org>,
        Eric Biederman <ebiederm@xmission.com>
Message-Id: <5872AE74-DF03-42E2-A21B-F8E35634CD1D@primarydata.com>
References: <20131201131441.790963326@bombadil.infradead.org> <20131201181329.GC10323@ZenIV.linux.org.uk> <20131202081233.GA6953@infradead.org> <3C65EB4C-6592-44F8-B08D-E5A9EFD6C8C6@primarydata.com> <529C982B.2030906@parallels.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 2, 2013, at 9:24, Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 02.12.2013 17:44, Trond Myklebust пишет:
>> 
>> On Dec 2, 2013, at 3:12, Christoph Hellwig <hch@infradead.org> wrote:
>> 
>>> On Sun, Dec 01, 2013 at 06:13:29PM +0000, Al Viro wrote:
>>>> Making the series no-go in that form, obviously.
>>> 
>>> Looking at the mess it made I'd almost be tempted to say a little leak
>>> for a less used features is better than lots of pain for everyone..
>>> 
>>> Looking at the mess it made I'm really upset.
>>> 
>>>>> Given that the namespace kraken has infected various internal filesystem
>>>>> and will get more soon I suspect this problem is or will become generic
>>>>> and will need a proper solution anyway.  Al, any good ideas how to deal
>>>>> with this?  Most straight forward way would be to add a counter of
>>>>> user vfsmount to the superblock and methods when it goes to 1 and 0,
>>>>> but that seems a bit ugly.
>>>> 
>>>> Folks, please, _please_, let's formulate the lifecycle rules first; we
>>>> already had way too much trouble from putting mechanism first only to
>>>> run into questions like the above ("what happens if somebody tries to
>>>> allocate a PID in pid_ns that is already scheduled for shutdown?").
>>>> Remember the (recurring) fun with kobject-related lifetime issues?
>>>> Or rpc_pipefs notifier ugliness, for that matter...
>>> 
>>> I'll have to let the net namespace folks chime in for that, as far as
>>> I'm concerned it's a featured better config'ed off.  If they can't come
>>> up with anything better the procfs hack above would be it.
>> 
>> The lifetime of the kernel mount only needs to match that of the rpc_client, since each rpc_client is associated to a single net namespace, and each net namespace is in a 1-1 relationship with an rpc_pipefs super block.
>> 
>> IOW: move the kernel mount/umount back to the rpc_client create/destroy methods and all should be well.
>> 
> 
> I'm sorry, guys, if I'm missing the point.
> But there was the reason, why all this notifier infrastructure was introduced:
> 
> "RPC pipefs superblock should holds network namespace while active."
> 
> And that's why:
> 
> "RPC pipefs mount can't be performed in kernel context since new super block
> will holds networks namespace reference and it's impossible to recognize, when
> and how we have to release this mount point."
> 
> https://lkml.org/lkml/2011/10/17/123
> 
> Circumstances has changed and now all this can be fixed much simplier?

I’m just pointing out that we _do_ know when the rpc_clients no longer needs to access the (per-net namespace) super block. Once we've destroyed the rpc_clients (well, OK, technically once we've destroyed the struct rpc_xprts) that refer to that net namespace, then the kernel no longer needs the super block to be mounted anywhere.

IOW: if we add back a rpc_get_mount(net)/rpc_put_mount(net), then we can call the former when creating the rpc_xprt, and the latter when destroying it. The rpc_pipefs super block is destroyed when both user space and the kernel have umounted it. i.e. when all NFS super blocks from that net name space have been destroyed and the container has unmounted rpc_pipefs.

No?

Cheers,
  Trond