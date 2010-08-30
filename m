Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755911Ab0H3Qx0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Aug 2010 12:53:26 -0400
Message-ID: <4C7BE1FC.2020400@RedHat.com>
Date: Mon, 30 Aug 2010 12:53:16 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, bfields@fieldses.org, chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>	<4C7BD394.3030705@RedHat.com> <20100830121600.529669bd@tlielax.poochiereds.net>
In-Reply-To: <20100830121600.529669bd@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/30/2010 12:16 PM, Jeff Layton wrote:
> On Mon, 30 Aug 2010 11:51:48 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 08/28/2010 07:35 AM, Jeff Layton wrote:
>>> There's a bit of a chicken and egg problem when nfsd is run the first
>>> time. On Fedora/RHEL at least, /proc/fs/nfsd is mounted up whenever nfsd
>>> is plugged in via a modprobe.conf "install" directive.
>>>
>>> If someone runs rpc.nfsd without plugging in nfsd.ko first,
>>> /proc/fs/nfsd won't be mounted and rpc.nfsd will end up using the legacy
>>> nfsctl interface. After that, nfsd will be plugged in and subsequent
>>> rpc.nfsd invocations will use that instead.
>>>
>>> This is a problem as some nfsd command-line options are ignored when the
>>> legacy interface is used. It'll also be a problem for people who want
>>> IPv6 enabled servers. The upshot is that we really don't want to use the
>>> legacy interface unless there is no other option.
>> Well maybe its time we stop supporting the legacy interface... I
>> would rather stop supporting something nobody uses then added
>> some questionable code... Lets just error out when /proc/fs/nfsd
>> is not mounted and log what needs to happen...
>>
>> steved.
>>
> 
> Hmmm...if I had known that it was ok to stop supporting old kernels,
> the IPv6 support for rpc.nfsd would have been a heck of a lot easier to
> implement.
I thought you said the legacy interface would not work with IPV6 or
did I misunderstand you? 

> 
> I'm not sure I like throwing up our hands and bailing out with a log
> message. We'll be going from an at least somewhat carefully considered
> fallback mechanism to an outright failure to start in this situation.
> That doesn't really seem like an improvement to me...
This case will only happen when people start rpc.nfsd by hand (i.e. not
via some start-up script) which %99.999 of the users do not do
.
But the few that do start rpc.nfsd by hand, they are probably debugging
something, so logging a message saying /proc/fs/nfsd is not mount 
would be quite handy... IMHO... 


> 
> How this as an alternate proposal?
> 
> We attempt to mount up nfsdfs. If the "threads" file still isn't
> present after the attempt, we then log a warning and go with the
> nfsctl() interface?
Has anybody test this legacy interface lately?? Does anybody anybody
depend on the existence of this interface??? I would guess the answer
would be no to both questions... So I see this as an opportunity so
simplify the code... which is always a good thing... 

So I would have no problem saying from the next release of nfs-utils,
the legacy interface is no longer supported... especially if there are
issues with IPV6.

steved.
