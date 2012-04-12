Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:56481 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870Ab2DLJGX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2012 05:06:23 -0400
Message-ID: <4F869AF7.10901@parallels.com>
Date: Thu, 12 Apr 2012 13:05:59 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
References: <20120410093900.20209d00@tlielax.poochiereds.net> <4F84493C.1040303@parallels.com> <20120410144505.58bca0b9@corrin.poochiereds.net> <4F855864.8050509@parallels.com> <20120411074822.0054eb36@tlielax.poochiereds.net> <4F85825E.4060104@parallels.com> <20120411171919.GA29903@fieldses.org> <4F85C15D.5060408@parallels.com> <20120411182218.GB31025@fieldses.org> <4F85DA84.8010703@parallels.com> <20120411221729.GG31706@fieldses.org>
In-Reply-To: <20120411221729.GG31706@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

12.04.2012 02:17, J. Bruce Fields пишет:
> On Wed, Apr 11, 2012 at 11:24:52PM +0400, Stanislav Kinsbursky wrote:
>> 11.04.2012 22:22, J. Bruce Fields написал:
>>>>>   What would happen, if we will have situation like below:
>>>>>   >   	mountd A	mountd B
>>>>>   >   	pid_ns		pid_ns
>>>>>   	|		  |
>>>>>   	mnt_ns		mnt_ns
>>>>>   	|		  |
>>>>>   	-----	net_ns ----
>>>>>   >   Is it possible, BTW?
>>>>>   It yes, that is such construction valid?
>>> Looks like a mess, no.  I'd expect there to be only one rpc.mountd
>>> running per network namespace.
>>
>> Then we have to prevent such situations somehow.
>> Or it is done already?
>
> If there's a way to prevent it, great, otherwise I think we just tell
> people not to do that, and make sure any distro scripts (or whatever)
> don't do that.
>

Sure, there is a way.
For example, mountd will need to ask kernel is he allowed to start or not. 
Kernel will have to compare starting mountd mount namespace with the mount 
namespace of the previous started mountd process. If they matches or previous 
mountd process is dead (or even never started), then new start is allowed.
And disallowed otherwise.

> Actually, my statement above isn't quite right: we do allow running
> multiple rpc.mountd processes in one network namespace (see the
> --num-threads option to rpc.mountd, which is sometimes necessary for
> performance).  But they should all be in the same namespaces and be
> using the same configuration.
>
> --b.


-- 
Best regards,
Stanislav Kinsbursky
