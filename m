From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RFC: merging sm-notify and rpc.statd
Date: Wed, 20 May 2009 12:38:10 -0400
Message-ID: <73F0D202-76BE-452C-8EF2-4881BDBB5BA1@oracle.com>
References: <E9DE1ACD-4C9D-43F8-9B00-28CE536BFDBD@oracle.com> <18963.13619.563465.804193@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:16424 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbZETQik (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 12:38:40 -0400
In-Reply-To: <18963.13619.563465.804193-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2009, at 6:39 PM, Neil Brown wrote:
> On Tuesday May 19, chuck.lever@oracle.com wrote:
>> Hi Neil-
>>
>> As part of IPv6 support for NFS, I've been looking at rpc.statd and  
>> sm-
>> notify.  IPv6 support touches so many parts of both, and the current
>> open-coded RPC request schedulers in both can't support netids  
>> without
>> major revision or replacement.  So I've decided to write a  
>> replacement
>> instead of grafting in support for IPv6 to the current  
>> implementation.
>>
>> For many reasons I'm thinking of merging sm-notify and rpc.statd back
>> together.  The two were split only a few years ago, and it seems to  
>> me
>> that it was done to support SuSE's in-kernel statd, which has since
>> been effectively abandoned.
>>
>> Having the two separated has ushered in a host of minor
>> complications.  Packaging and init-scripts are more complicated.   
>> Both
>> executables have separate knowlege about /var/lib/nfs/{sm,sm.bak}.
>> There are two separate man pages that share a lot of the same  
>> content.
>>
>> So, what do you think about folding sm-notify back into rpc.statd?
>> Steve suggested there may have been a customer issue that drove the
>> separation.  Do you have any recollection of the issues?
>>
>> For the rest of the list: are there strong dependencies outside RH  
>> and
>> SuSE distributions that would require a separate sm-notify
>> executable?  Any other issues?
>
> While the separation of sm-notify was presumably driven by the suse
> in-kernel statd, that wasn't the reason that I copied the idea in
> nfs-utils.
>
> sm-notify and statd really have two very different tasks.
>
> sm-notify :
>   - is a 'client' for the "SM" protocol.
>   - must be run at boot time, and after that is not needed.

> statd :
>   - is a 'server' for the "SM" protocol.
>   - only needs to be running when either nfsd is running or an
>     nfs mount which supports locks is active
>
> Thus I feel they are conceptually quite distinct.

There are details that make it not such a clean conceptual break:

  o  Who manages the NSM state number?  sm-notify sends it out to  
remote peers, and statd returns it in SM_MON and SM_UNMON replies.   
There has to be some co-ordination of how the state number is  
updated.  If sm-notify runs separately (for example, with the "-- 
force" option) and updates the state number, how does statd know  
there's a new state number?  If lockd isn't loaded and running when sm- 
notify runs, how is the kernel going to get the right NSM state number?

  o  statd still has client duties: it has to post NLM callbacks to  
the local lockd.  Sending notifications to remote peers is not so  
different from that, conceptually.  One could argue, therefore, that  
we should split that piece out of statd as well, but that would mean  
we fork/exec every time we get an unauthenticated SM_NOTIFY request  
from a monitored peer.  That exposes a DoS vulnerability.

  o  statd has to wait while sm-notify copies the monitor list.  It  
really shouldn't accept SM_MON requests while the notification list is  
created.  But if it waits for long, it will appear that the NSM  
service has died.  So there is some non-trivial synchronization  
between the two, and that appears to be split between statd and sm- 
notify today (and that synchronization requirement isn't documented in  
any way).

  o  statd has to fire up sm-notify when it receives SM_SIMU_CRASH.   
Today our lockd doesn't send that, but it could in the future.  So, sm- 
notify is not strictly an "only-at-reboot" kind of affair.

  o  sm-notify tries to do a sync(2) to make sure that the file system  
state is made permanent after an NSM state update.  Bruce has  
suggested doing the sync only after the first SM_MON (to reduce  
overhead during system boot), but that moves the sync(2) far away from  
the logic that updates the state number.  That exposes us to NSM state  
number walk-back if the system crashes at the wrong time.  It's  
arguable how much of a problem that is.

  o  It is better to send notifications when lockd is up.  For  
clients, at least, lockd comes up only after the first NFS mount, and  
in automounter scenarios, that may not be for some time after a  
reboot.  Servers may not start nfslock until they do "service nfslock  
start; service nfs start" at some point possibly long after reboot.   
So should clients be notified right when the server peer starts up, or  
after the server peer has fired up its NFSD and lockd service?

  o  Those who package statd/sm-notify have to understand how these  
operate.  The people who create system init-scripts are generally not  
NFS experts, thus they must have local knowledge about statd and sm- 
notify in order to get this all correct.  It would be more fool-proof  
if we hard-coded the start-up behavior, and took it out of the hands  
of the init-scripts folks, whom we do not control.  How do we document  
the operational dependencies in a way that makes it very hard for non- 
NFS folks to set this up incorrectly?  One way is to build it all in a  
single program.

> It is probably true that they could share a slab of code, and putting
> that code in a common .c file would make a lot of sense.

Yes, I've started doing that to try to understand what code can be  
shared.

> I am not strongly against re-uniting them.  However before doing that,
> I think it would be a good idea to collect a list of the problems that
> would be solved by unifying them, and the asking the question: is
> unifying them the only or best solution to these problems.

Agreed.  See above.

If there are one or more strong reasons to keep these separate, I can  
go down that road.  But I think the practical matters of making NSM  
work in multiple Linux distributions, each with their own packaging  
and init-script mechanisms and requirements, suggests we'd be better  
off making it simple to get this right.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
