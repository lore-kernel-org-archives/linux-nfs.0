From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RFC: merging sm-notify and rpc.statd
Date: Thu, 21 May 2009 13:14:59 -0400
Message-ID: <3BDE0EEC-A61A-41AF-8AC5-A8C9578AEC17@oracle.com>
References: <E9DE1ACD-4C9D-43F8-9B00-28CE536BFDBD@oracle.com> <18963.13619.563465.804193@notabene.brown> <73F0D202-76BE-452C-8EF2-4881BDBB5BA1@oracle.com> <18964.39373.232045.96215@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:21861 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542AbZEURPK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 May 2009 13:15:10 -0400
In-Reply-To: <18964.39373.232045.96215-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 20, 2009, at 8:01 PM, Neil Brown wrote:
> On Wednesday May 20, chuck.lever@oracle.com wrote:
>> On May 19, 2009, at 6:39 PM, Neil Brown wrote:
>>> On Tuesday May 19, chuck.lever@oracle.com wrote:
>>>> Hi Neil-
>>>>
>>>> As part of IPv6 support for NFS, I've been looking at rpc.statd and
>>>> sm-
>>>> notify.  IPv6 support touches so many parts of both, and the  
>>>> current
>>>> open-coded RPC request schedulers in both can't support netids
>>>> without
>>>> major revision or replacement.  So I've decided to write a
>>>> replacement
>>>> instead of grafting in support for IPv6 to the current
>>>> implementation.
>>>>
>>>> For many reasons I'm thinking of merging sm-notify and rpc.statd  
>>>> back
>>>> together.  The two were split only a few years ago, and it seems to
>>>> me
>>>> that it was done to support SuSE's in-kernel statd, which has since
>>>> been effectively abandoned.
>>>>
>>>> Having the two separated has ushered in a host of minor
>>>> complications.  Packaging and init-scripts are more complicated.
>>>> Both
>>>> executables have separate knowlege about /var/lib/nfs/{sm,sm.bak}.
>>>> There are two separate man pages that share a lot of the same
>>>> content.
>>>>
>>>> So, what do you think about folding sm-notify back into rpc.statd?
>>>> Steve suggested there may have been a customer issue that drove the
>>>> separation.  Do you have any recollection of the issues?
>>>>
>>>> For the rest of the list: are there strong dependencies outside RH
>>>> and
>>>> SuSE distributions that would require a separate sm-notify
>>>> executable?  Any other issues?
>>>
>>> While the separation of sm-notify was presumably driven by the suse
>>> in-kernel statd, that wasn't the reason that I copied the idea in
>>> nfs-utils.
>>>
>>> sm-notify and statd really have two very different tasks.
>>>
>>> sm-notify :
>>>  - is a 'client' for the "SM" protocol.
>>>  - must be run at boot time, and after that is not needed.
>>
>>> statd :
>>>  - is a 'server' for the "SM" protocol.
>>>  - only needs to be running when either nfsd is running or an
>>>    nfs mount which supports locks is active
>>>
>>> Thus I feel they are conceptually quite distinct.
>>
>> There are details that make it not such a clean conceptual break:
>>
>>  o  Who manages the NSM state number?  sm-notify sends it out to
>> remote peers, and statd returns it in SM_MON and SM_UNMON replies.
>> There has to be some co-ordination of how the state number is
>> updated.  If sm-notify runs separately (for example, with the "--
>> force" option) and updates the state number, how does statd know
>> there's a new state number?  If lockd isn't loaded and running when  
>> sm-
>> notify runs, how is the kernel going to get the right NSM state  
>> number?
>
> sm-notify manages the state number.
> statd must ensure that sm-notify has run before it reads the number
> from the file.  As sm-notify has its own locking to ensure it is run
> only once, statd simple runs sm-notify before proceeded.
> sm-notify explicitly tells the kernel what the state number is.

Except in the SM_SIMU_CRASH case.  sm-notify updates the on-disk state  
number, but today, statd reads the state number once at start-up, and  
never updates it.  So it would miss that case; lockd and statd would  
continue to advertise the old state number.  (I think statd is also  
supposed to simulate a crash if it gets SIGUSR1).

> If the lockd modules isn't loaded when sm-notify runs that might be a
> small problem.

That is a frequent problem on today's clients.  lockd isn't loaded by / 
etc/init.d/nfslock unless there are module parameters specified (which  
in most cases, there aren't).  The state number is also lost if, for  
instance, the number of NFS mounts goes to zero and lockd is  
unloaded.  This can easily happen on clients that manage their NFS  
mounts with automounter.

In my experience our clients almost always send a zero state number  
today.

One could even go so far as to argue that an unload-load of lockd  
counts as a reboot (in terms of NSM state number management), and thus  
we should increment the NSM state number in that case to ensure that  
clients and servers start with a clean slate.

>  I'd have to remind my self of all the details of the
> lockd protocols to be sure what was needed.  Maybe statd should tell
> it to lockd when it first hears from lockd.

I've sent a patch to Trond to change lockd to pick up the state number  
from SM_MON replies.  lockd could also do an SM_UNMON_ALL when it is  
first loaded, and pick up the state number from its reply.

>>  o  statd still has client duties: it has to post NLM callbacks to
>> the local lockd.  Sending notifications to remote peers is not so
>> different from that, conceptually.  One could argue, therefore, that
>> we should split that piece out of statd as well, but that would mean
>> we fork/exec every time we get an unauthenticated SM_NOTIFY request
>> from a monitored peer.  That exposes a DoS vulnerability.
>
> Yes, client duties.  But a client for a different protocol.
> I think we have a strawman argument here.  I would certainly never
> suggest that the lockd call back should be done by a separate process.
>
> At it's core, statd works like this:
>   lockd says to statd "Tell me if X restarts, and tell X if I  
> restart".
>   So statd listen for X to say "I have restarted" and passes that on
>   to to lockd.
>   Statd cannot directly tell X that it has restarted because it will
>   have died first.  So it leaves a note (on the fridge) for someone
>   else to do it.  That "someone else" is sm-notify.
>   So sm-notify is running on behalf of the statd from before the last
>   reboot.  In that sense it is quite separate from the currently
>   running statd.
>
>>  o  statd has to wait while sm-notify copies the monitor list.  It
>> really shouldn't accept SM_MON requests while the notification list  
>> is
>> created.  But if it waits for long, it will appear that the NSM
>> service has died.  So there is some non-trivial synchronization
>> between the two, and that appears to be split between statd and sm-
>> notify today (and that synchronization requirement isn't documented  
>> in
>> any way).
>
> Sounds like there could be an implementation problem here.
> I don't think sm-notify need to copy the monitor list exactly.  It
> just needs to move it out of the way so statd has a clean slate.
>   mv /var/lib/nfs/sm /var/lib/nfs/sm.bak.$UNIQUE
>   mkdir /var/lib/nfs/sm
>   # let statd continue
>   # shuffle through files in /var/lib/nfs/sm.bak*

The current implementation is careful to preserve some or all existing  
files in sm.bak.  Basically if a previous notification never  
succeeded, the file for that peer stays in sm.bak, and sm-notify will  
try to notify that host again during the next reboot.  So, a file can  
be overwritten, but files for old peers are preserved in this case.

This seems reasonable to ensure peers are notified, although we may  
get a growing number of files in some situations.  We could assess a  
timeout -- after 5 reboots, we can be fairly certain the peer isn't  
coming back, and that the file should be removed.

> And while I agree that more documentation is a good thing, I think the
> synchronization is enforced so documentation isn't essential.
> statd runs sm-notify before doing anything.  sm-notify does the
> minimum for synchronization before forking and exiting and allowing
> statd to continue. (or maybe not as I discover below)

There is a rather mysterious sequence of forks at start up, and we  
happen to get this behavior today.  It's not terribly straightforward,  
and could be removed by someone in the future who is trying to reduce  
complexity.  Anyway...

>>  o  statd has to fire up sm-notify when it receives SM_SIMU_CRASH.
>> Today our lockd doesn't send that, but it could in the future.  So,  
>> sm-
>> notify is not strictly an "only-at-reboot" kind of affair.
>
> True, but not a strong case for anything I would think.
>
>>
>>  o  sm-notify tries to do a sync(2) to make sure that the file system
>> state is made permanent after an NSM state update.  Bruce has
>> suggested doing the sync only after the first SM_MON (to reduce
>> overhead during system boot), but that moves the sync(2) far away  
>> from
>> the logic that updates the state number.  That exposes us to NSM  
>> state
>> number walk-back if the system crashes at the wrong time.  It's
>> arguable how much of a problem that is.
>
> Sounds like there is room for improvement here, definitely.
>
> This is only a half-formed idea, but:
>  sm-notify could update 'state' to an odd number if it is even, but
>     not sync anything
>  statd, on the first SM_MON, updates 'state' to an even number if it
>     was odd and in that case does the required sync.

That would still provide an opportunity for state number replay, which  
would make at least one subsequent notification a no-op.

Given recent discussions on lkml about the behavior of sync/fsync with  
regard to renames, unlinks, file creation and the like, I think we  
should be more conservative about this, not less.  (In fact my current  
prototype uses sqlite3 instead of flat files for all of this).

> I would need to check the protocol and the code and do a bit of case
> analysis to be sure I had that right, but I suspect it is close.
> (or it could be made completely irrelevant but subsequent
>  observations.  Read on!)
>
>>  o  It is better to send notifications when lockd is up.  For
>> clients, at least, lockd comes up only after the first NFS mount, and
>> in automounter scenarios, that may not be for some time after a
>> reboot.  Servers may not start nfslock until they do "service nfslock
>> start; service nfs start" at some point possibly long after reboot.
>> So should clients be notified right when the server peer starts up,  
>> or
>> after the server peer has fired up its NFSD and lockd service?
>
> When a client notifies a server that it has rebooted, the server
> simply drops the locks.  There is no need for the client lockd to be
> running.

Agreed.  However, at least for Linux, statd is used on both the client  
and server, and a system can act as both concurrently.  There's no  
real way for statd to distinguish between remote clients and servers  
from an SM_MON request.

> When a server notifies a client that it has rebooted, the client tries
> to reclaim the locks.  So the server lockd *must* be running at that
> time.  It is not a case of 'better'.  It is 'must'.

Jeff Layton observed Solaris NFS servers (the reference NFSv2/v3  
implementation) sending reboot notifications before their lockd is  
alive.  That's why I qualified the requirement.

> So if a machine is an NFS server that plans to keep serving, it must
> start nfsd (and hence lockd) before running sm-notify.
>
> However it is good to have statd running before lockd, as lockd needs
> to talk to statd.
> So there order seems to be:
>  statd
>  nfsd and hence lockd
>  sm-notify
>
> which is clearly documented in the README, but seems to disagree with
> what we said above :-)
> We want to clean out the 'sm' directory, then run statd/nfsd/lockd,
> then sm-notify reads the sm.bak and sends off the notifications.
>
> There does seem to be room for improvement here.  And I feel that
> having sm-notify separate actually makes it easier to get this
> right...
>
> How about this for a bit of a left-field idea:
> - files representing monitored hosts are stored in
>         /var/lib/nfs/sm.$STATE
> - At reboot, /var/lib/nfs/state is incremented (twice?) but not
>    synced.
> - statd, on first SM_MON creates /var/lib/nfs/sm.$STATE if needed,
>   based on the value in the 'state' file, and does the required
>   sync at that point
> - sm-notify can be run at any time after nfsd (if required) is
>   started,  and send notification to any host in a sm.$STATE where
>   $STATE < 'state'.  The 'state' number in the notification is
>   $STATE (or is it $STATE+1??)

sm-notify should send the same NSM state number as lockd is sending in  
NLMPROC_LOCK requests.  afaict only odd state numbers are passed  
between peers.

>>  o  Those who package statd/sm-notify have to understand how these
>> operate.  The people who create system init-scripts are generally not
>> NFS experts, thus they must have local knowledge about statd and sm-
>> notify in order to get this all correct.  It would be more fool-proof
>> if we hard-coded the start-up behavior, and took it out of the hands
>> of the init-scripts folks, whom we do not control.  How do we  
>> document
>> the operational dependencies in a way that makes it very hard for  
>> non-
>> NFS folks to set this up incorrectly?  One way is to build it all  
>> in a
>> single program.
>
> That is a strong argument.  It is probably part of the argument for
> putting it all in the kernel too.

Putting it _all_ in the kernel is a challenge.  One issue is that the  
kernel should never write into local files, so some user space  
interaction is rather a requirement.

However, I think a scheme where the kernel provides the NSM service  
listener, and exposes its NSM cache to user space via rpc_pipefs or  
some other mechanism might be better than having lockd post SM_MON/ 
SM_UNMON requests and listen for NLM callbacks from statd.

The kernel can provide more information about the remote peer:  the IP  
address it used to contact us; the transport protocol it used to  
contact us; and whether it is a client or a server peer.  None of that  
information is available in the NSM protocol today.

The kernel also knows for certain when reboots occur, and when server- 
side grace period starts and ends.

That's a future idea, though.  Right now we just need something that  
supports IPv6.

> A valid question is: *can* we build it all into a single program?
>
> Given that:
>  state and sm need to be updated before statd responds to SM_MON
>  statd should be ready to respond to SM_MON before lockd starts
>  exportfs -av must be run before nfsd starts
>  nfsd and lockd must start before notifications are sent on a server
>  notifications (from the server) must be sent promptly after
>     nfsd starts its grace period.

Perhaps another desirable characteristic would be to curtail or stop  
notification once the grace period ends.

But it seems to me that start of the grace period is when you want to  
post SM_NOTIFY requests.  And statd can't possibly know when that is  
unless lockd tells it.

> I find it hard to see a single statd being able to do the whole thing.

> We have a 'README' to document the order.  We could provide a sample
> startup script.  I don't think we *can* provide a "get it all right"
> program.

I don't see anything in your argument why it can't be done in a single  
program, but could be done in an init script (or two).

statd could, for example, listen for signals to determine when to fire  
off sm-notify.  It already listens for SIGUSR1 today.  Or, we could  
require the kernel to post an SM_SIMU_CRASH when it is ready for statd  
to send notifications.  (That's one reason I brought up SM_SIMU_CRASH  
above).

So I guess my argument is that we can do this in a single program if  
we use a little more of the NSM protocol, ensuring that lockd  
communicates a little more with statd.

>> If there are one or more strong reasons to keep these separate, I can
>> go down that road.  But I think the practical matters of making NSM
>> work in multiple Linux distributions, each with their own packaging
>> and init-script mechanisms and requirements, suggests we'd be better
>> off making it simple to get this right.
>
> "simple to get this right" is certainly good.
> But "right" must over-rule "simple", and it seems like we might not
> even really be at "right" yet. :-(
>
> Maybe the way to make sure people get it work is to detect broken
> configurations and fail horribly...

As Greg likes to say:  "Meh."  I think everyone will be better off if  
we try to get it all to work automatically.  With warnings, we then  
depend on the patience of distributors and administrators to  
troubleshoot this.  It should "just work."

> So:
>  sm-notify performs its own /var/run locking to make sure it is only
>   run once (plus allow for --simu-crash??)
>   It quickly updates /var/lib/nfs/ (which no sync) and then checks
>   to see if mountd is running.  If it is, it assume 'server' and
>   waits a while for lockd to appear (both checks via portmap).
>   Once lockd is running (or mountd was not), it sends out
>   notifications.
>  mountd checks if sm-notify has already run (via the /var/run file),
>   and complains gently, maybe only if it is less than a few minutes
>   before boot.  e.g.
>    WARNING: during boot, mountd must be run before sm-notify!
>
>  statd always runs sm-notify first and waits for it to exit, which
>    it does once it has moved things aside and updated 'state'.
>    On the first SM_MON call, statd calls 'fsync' on 'state' and
>    related directories, and writes the 'state' value to the
>    kernel....  which is moments to late.  The kernel has already
>    used it.

The state number is returned in the SM_MON reply.  As mentioned, I  
sent Trond a patch for client side to dig that out before posting an  
NLMPROC_LOCK request.  The server side doesn't seem to care what its  
local NSM state is.

>  Maybe we need a call to nsm_monitor in nlmclnt_proc,
>    and maybe _reclaim and _cancel too - not sure
>
>  mount.nfs makes sure statd is running - we already have that.

We also have lockd checking that statd is running via an SM_MON upcall  
before sending the first NLM request on this mount point (yes, and  
that check is actually working in 2.6.29!  it now refuses to allow a  
lock operation if it can't contact statd).  Do we need both?

>   rpc.nfsd can complain if statd is not already running, or maybe
>    even just start it.

> That, I think, should enforce some of the ordering, and complain
> if other ordering requirements aren't met.
>
> And just for the record: my strongest argument for keeping them
> separate is that statd (being network service) should only be started
> if and when it is actually needed, while sm-notify should always be
> run at boot in case it has some cleaning up to do.

OK, noted.  I take it this is more of a security thing -- try to limit  
network service exposure when possible.

I know that Linux statd has a checkered security past, but it seems  
that we're not terribly consistent on this front with other services.   
rpcbind is always running whether we have NFSD and NFS mounts or not.   
rpcbind, statd and lockd are running when we have only NFSv4 mounts,  
and rpcbind and statd run when we have no mounts at all.

Systems that don't want NFS can simply avoid starting /etc/init.d/ 
nfslock and /etc/init.d/nfs at boot time. IMO that's enough -- the  
added dynamic starting up and shutting down of these services makes  
them much more complex and fragile than needed.

There is only a single case I can think of where we might want  
notification, but not want to start statd.  That is when an admin  
decides to disable NFS on a system.  One last notification is  
appropriate, but statd shouldn't be started.  We could probably  
accomplish this with the "notify then exit" option on statd.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
