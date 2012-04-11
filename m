Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36503 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab2DKNJI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2012 09:09:08 -0400
Message-ID: <4F85825E.4060104@parallels.com>
Date: Wed, 11 Apr 2012 17:08:46 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>	<4F841D2A.9020504@parallels.com>	<20120410081612.65dd25fa@tlielax.poochiereds.net>	<4F842BAE.2010804@parallels.com>	<20120410093900.20209d00@tlielax.poochiereds.net>	<4F84493C.1040303@parallels.com>	<20120410144505.58bca0b9@corrin.poochiereds.net>	<4F855864.8050509@parallels.com> <20120411074822.0054eb36@tlielax.poochiereds.net>
In-Reply-To: <20120411074822.0054eb36@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.04.2012 15:48, Jeff Layton пишет:
>>>>> One thing that puzzles me at the moment. We have two namespaces to deal
>>>>> with -- the network and the mount namespace. With nfs client code,
>>>>> everything is keyed off of the net namespace. That's not really the
>>>>> case here since we have to deal with a local fs tree as well.
>>>>>
>>>>> When an nfsd running in a container receives an RPC, how does it
>>>>> determine what mount namespace it should do its operations in?
>>>>>
>>>>
>>>> We don't use mount namespaces, so that's why I wasn't thinking about it...
>>>> But if we have 2 types of namespaces, then we have to tie  mount namesapce to
>>>> network. I.e we can get desired mount namespace from per-net NFSd data.
>>>>
>>>
>>> One thing that Bruce mentioned to me privately is that we could plan to
>>> use whatever mount namespace mountd is using within a particular net
>>> namespace. That makes some sense since mountd is the final arbiter of
>>> who gets access to what.
>>>
>>
>> Could you, please, give some examples? I don't get the idea.
>>
>
> When nfsd gets an RPC call, it needs to decide in what mount namespace
> to do the fs operations. How do we decide this?
>
> Bruce's thought was to look at what mount namespace rpc.mountd is using
> and use that, but now that I consider it, it's a bit of a chicken and
> egg problem really... nfsd talks to mountd via files in /proc/net/rpc/.
> In order to talk to the right mountd, might you need to know what mount
> namespace it's operating in?
>

Not really... /proc itself depens on pid namespace. /proc/net depends on current 
(!) network namespace. So we can't just lookup for this dentry.

But, in spite of nfsd works in initial (init_net and friends) environment, we 
can get network namespace from RPC request. Having this, we can easily get 
desired proc entry (proc_net_rpc in sunrpc_net). So it looks like we can 
actually don't care about mount namespaces - we have our own back door.
If I'm not mistaken, of course...

> A simpler method might be to take a reference to whatever mount
> namespace rpc.nfsd has when it starts knfsd and keep that reference
> inside of the nfsd_net struct. When a call comes in to a particular
> nfsd "instance" you can just use that mount namespace.
>

This means that we tie mount namespace to network. Even worse - network 
namespace holds mount namespace. Currently, I can't see any problems. But I 
can't even imagine, how many pitfalls can (and, most probably, will) be found in 
future.
I think, we should try to avoid explicit cross-namespaces dependencies...

>>> Note that it is quite easy to get lost in the weeds with this. I've been
>>> struggling to get a working design for a clustered nfsv4 server for the
>>> last several months and have had some time to wrestle with these
>>> issues. It's anything but trivial.
>>>
>>> What you may need to do in order to make progress is to start with some
>>> valid use-cases for this stuff, and get those working while disallowing
>>> or ignoring other use cases. We'll never get anywhere if we try to solve
>>> all of these problems at once...
>>>
>>
>> Agreed.
>> So, my current understanding of the situation can be summarized as follows:
>>
>> 1) The idea of making grace period (and int internals) per networks namespace
>> stays the same. But it's implementation affect only current "generic grace
>> period" code.
>>
>
> Yes, that's where you should focus your efforts for now. As I said, we
> don't have any alternate grace period handling schemes yet, but we will
> eventually need one to handle clustered filesystems and possibly the
> case of serving the same local fs from multiple namespaces.
>

Ok.

>> 2) Your idea of making grace period per file system looks reasonable. And maybe
>> this approach (using of filesystem's export operations if available) have to be
>> used by default.
>> But I suggest to add new option to exports (say, "no_fs_grace"), which will
>> disable this new functionality. With this option system administrator becomes
>> responsible for any problems with shared file system.
>>
>
> Something like that may be a reasonable hack initially but we need to
> ensure that we can deal with this properly later. I think we're going
> to end up with "pluggable" grace period handling at some point, so it
> may be more future proof to do something like "grace=simple" or
> something instead of no_fs_grace. Still...
>
> This is a complex enough problem that I think it behooves us to
> consider it very carefully and come up with a clear design before we
> code anything. We need to ensure that whatever we do doesn't end up
> hamstringing other use cases later...
>
> We have 3 cases that I can see that we're interested in initially.
> There is some overlap between them however:
>
> 1) simple case of a filesystem being exported from a single namespace.
> This covers non-containerized nfsd and containerized nfsd's that are
> serving different filesystems.
>
> 2) a containerized nfsd that serves the same filesystem from multiple
> namespaces.
>
> 3) a cluster serving the same filesystem from multiple namespaces. In
> this case, the namespaces are also potentially spread across multiple
> nodes as well.
>
> There's a lot of overlap between #2 and #3 here.

Yep, sure. I have nothing to add or object here.

-- 
Best regards,
Stanislav Kinsbursky
