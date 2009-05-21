From: Neil Brown <neilb@suse.de>
Subject: Re: RFC: merging sm-notify and rpc.statd
Date: Thu, 21 May 2009 10:01:17 +1000
Message-ID: <18964.39373.232045.96215@notabene.brown>
References: <E9DE1ACD-4C9D-43F8-9B00-28CE536BFDBD@oracle.com>
	<18963.13619.563465.804193@notabene.brown>
	<73F0D202-76BE-452C-8EF2-4881BDBB5BA1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46411 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756273AbZEUABM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 20:01:12 -0400
In-Reply-To: message from Chuck Lever on Wednesday May 20
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday May 20, chuck.lever@oracle.com wrote:
> On May 19, 2009, at 6:39 PM, Neil Brown wrote:
> > On Tuesday May 19, chuck.lever@oracle.com wrote:
> >> Hi Neil-
> >>
> >> As part of IPv6 support for NFS, I've been looking at rpc.statd and  
> >> sm-
> >> notify.  IPv6 support touches so many parts of both, and the current
> >> open-coded RPC request schedulers in both can't support netids  
> >> without
> >> major revision or replacement.  So I've decided to write a  
> >> replacement
> >> instead of grafting in support for IPv6 to the current  
> >> implementation.
> >>
> >> For many reasons I'm thinking of merging sm-notify and rpc.statd back
> >> together.  The two were split only a few years ago, and it seems to  
> >> me
> >> that it was done to support SuSE's in-kernel statd, which has since
> >> been effectively abandoned.
> >>
> >> Having the two separated has ushered in a host of minor
> >> complications.  Packaging and init-scripts are more complicated.   
> >> Both
> >> executables have separate knowlege about /var/lib/nfs/{sm,sm.bak}.
> >> There are two separate man pages that share a lot of the same  
> >> content.
> >>
> >> So, what do you think about folding sm-notify back into rpc.statd?
> >> Steve suggested there may have been a customer issue that drove the
> >> separation.  Do you have any recollection of the issues?
> >>
> >> For the rest of the list: are there strong dependencies outside RH  
> >> and
> >> SuSE distributions that would require a separate sm-notify
> >> executable?  Any other issues?
> >
> > While the separation of sm-notify was presumably driven by the suse
> > in-kernel statd, that wasn't the reason that I copied the idea in
> > nfs-utils.
> >
> > sm-notify and statd really have two very different tasks.
> >
> > sm-notify :
> >   - is a 'client' for the "SM" protocol.
> >   - must be run at boot time, and after that is not needed.
> 
> > statd :
> >   - is a 'server' for the "SM" protocol.
> >   - only needs to be running when either nfsd is running or an
> >     nfs mount which supports locks is active
> >
> > Thus I feel they are conceptually quite distinct.
> 
> There are details that make it not such a clean conceptual break:
> 
>   o  Who manages the NSM state number?  sm-notify sends it out to  
> remote peers, and statd returns it in SM_MON and SM_UNMON replies.   
> There has to be some co-ordination of how the state number is  
> updated.  If sm-notify runs separately (for example, with the "-- 
> force" option) and updates the state number, how does statd know  
> there's a new state number?  If lockd isn't loaded and running when sm- 
> notify runs, how is the kernel going to get the right NSM state number?

sm-notify manages the state number.
statd must ensure that sm-notify has run before it reads the number
from the file.  As sm-notify has its own locking to ensure it is run
only once, statd simple runs sm-notify before proceeded.
sm-notify explicitly tells the kernel what the state number is.

If the lockd modules isn't loaded when sm-notify runs that might be a
small problem.  I'd have to remind my self of all the details of the
lockd protocols to be sure what was needed.  Maybe statd should tell
it to lockd when it first hears from lockd.

> 
>   o  statd still has client duties: it has to post NLM callbacks to  
> the local lockd.  Sending notifications to remote peers is not so  
> different from that, conceptually.  One could argue, therefore, that  
> we should split that piece out of statd as well, but that would mean  
> we fork/exec every time we get an unauthenticated SM_NOTIFY request  
> from a monitored peer.  That exposes a DoS vulnerability.

Yes, client duties.  But a client for a different protocol.
I think we have a strawman argument here.  I would certainly never
suggest that the lockd call back should be done by a separate process.

At it's core, statd works like this:
   lockd says to statd "Tell me if X restarts, and tell X if I restart".
   So statd listen for X to say "I have restarted" and passes that on
   to to lockd.
   Statd cannot directly tell X that it has restarted because it will
   have died first.  So it leaves a note (on the fridge) for someone
   else to do it.  That "someone else" is sm-notify.
   So sm-notify is running on behalf of the statd from before the last
   reboot.  In that sense it is quite separate from the currently
   running statd.

> 
>   o  statd has to wait while sm-notify copies the monitor list.  It  
> really shouldn't accept SM_MON requests while the notification list is  
> created.  But if it waits for long, it will appear that the NSM  
> service has died.  So there is some non-trivial synchronization  
> between the two, and that appears to be split between statd and sm- 
> notify today (and that synchronization requirement isn't documented in  
> any way).

Sounds like there could be an implementation problem here.
I don't think sm-notify need to copy the monitor list exactly.  It
just needs to move it out of the way so statd has a clean slate.
   mv /var/lib/nfs/sm /var/lib/nfs/sm.bak.$UNIQUE
   mkdir /var/lib/nfs/sm
   # let statd continue
   # shuffle through files in /var/lib/nfs/sm.bak*

And while I agree that more documentation is a good thing, I think the
synchronization is enforced so documentation isn't essential.
statd runs sm-notify before doing anything.  sm-notify does the
minimum for synchronization before forking and exiting and allowing
statd to continue. (or maybe not as I discover below)

> 
>   o  statd has to fire up sm-notify when it receives SM_SIMU_CRASH.   
> Today our lockd doesn't send that, but it could in the future.  So, sm- 
> notify is not strictly an "only-at-reboot" kind of affair.

True, but not a strong case for anything I would think.

> 
>   o  sm-notify tries to do a sync(2) to make sure that the file system  
> state is made permanent after an NSM state update.  Bruce has  
> suggested doing the sync only after the first SM_MON (to reduce  
> overhead during system boot), but that moves the sync(2) far away from  
> the logic that updates the state number.  That exposes us to NSM state  
> number walk-back if the system crashes at the wrong time.  It's  
> arguable how much of a problem that is.

Sounds like there is room for improvement here, definitely.

This is only a half-formed idea, but:
  sm-notify could update 'state' to an odd number if it is even, but
     not sync anything
  statd, on the first SM_MON, updates 'state' to an even number if it
     was odd and in that case does the required sync.

 I would need to check the protocol and the code and do a bit of case
 analysis to be sure I had that right, but I suspect it is close.
 (or it could be made completely irrelevant but subsequent
  observations.  Read on!)
  

> 
>   o  It is better to send notifications when lockd is up.  For  
> clients, at least, lockd comes up only after the first NFS mount, and  
> in automounter scenarios, that may not be for some time after a  
> reboot.  Servers may not start nfslock until they do "service nfslock  
> start; service nfs start" at some point possibly long after reboot.   
> So should clients be notified right when the server peer starts up, or  
> after the server peer has fired up its NFSD and lockd service?
> 

When a client notifies a server that it has rebooted, the server
simply drops the locks.  There is no need for the client lockd to be
running.

When a server notifies a client that it has rebooted, the client tries
to reclaim the locks.  So the server lockd *must* be running at that
time.  It is not a case of 'better'.  It is 'must'.
So if a machine is an NFS server that plans to keep serving, it must
start nfsd (and hence lockd) before running sm-notify.

However it is good to have statd running before lockd, as lockd needs
to talk to statd.
So there order seems to be:
  statd
  nfsd and hence lockd
  sm-notify

which is clearly documented in the README, but seems to disagree with
what we said above :-)
We want to clean out the 'sm' directory, then run statd/nfsd/lockd,
then sm-notify reads the sm.bak and sends off the notifications.

There does seem to be room for improvement here.  And I feel that
having sm-notify separate actually makes it easier to get this
right...

How about this for a bit of a left-field idea:
 - files representing monitored hosts are stored in
         /var/lib/nfs/sm.$STATE
 - At reboot, /var/lib/nfs/state is incremented (twice?) but not
    synced.
 - statd, on first SM_MON creates /var/lib/nfs/sm.$STATE if needed,
   based on the value in the 'state' file, and does the required
   sync at that point
 - sm-notify can be run at any time after nfsd (if required) is
   started,  and send notification to any host in a sm.$STATE where
   $STATE < 'state'.  The 'state' number in the notification is
   $STATE (or is it $STATE+1??)


>   o  Those who package statd/sm-notify have to understand how these  
> operate.  The people who create system init-scripts are generally not  
> NFS experts, thus they must have local knowledge about statd and sm- 
> notify in order to get this all correct.  It would be more fool-proof  
> if we hard-coded the start-up behavior, and took it out of the hands  
> of the init-scripts folks, whom we do not control.  How do we document  
> the operational dependencies in a way that makes it very hard for non- 
> NFS folks to set this up incorrectly?  One way is to build it all in a  
> single program.

That is a strong argument.  It is probably part of the argument for
putting it all in the kernel too.
A valid question is: *can* we build it all into a single program?

Given that:
  state and sm need to be updated before statd responds to SM_MON
  statd should be ready to respond to SM_MON before lockd starts
  exportfs -av must be run before nfsd starts
  nfsd and lockd must start before notifications are sent on a server
  notifications (from the server) must be sent promptly after
     nfsd starts its grace period.

I find it hard to see a single statd being able to do the whole thing.

We have a 'README' to document the order.  We could provide a sample
startup script.  I don't think we *can* provide a "get it all right"
program.

> 
> If there are one or more strong reasons to keep these separate, I can  
> go down that road.  But I think the practical matters of making NSM  
> work in multiple Linux distributions, each with their own packaging  
> and init-script mechanisms and requirements, suggests we'd be better  
> off making it simple to get this right.

"simple to get this right" is certainly good.
But "right" must over-rule "simple", and it seems like we might not
even really be a "right" yet. :-(

Maybe the way to make sure people get it work is to detect broken
configurations and fail horribly...
So:
  sm-notify performs its own /var/run locking to make sure it is only
   run once (plus allow for --simu-crash??)
   It quickly updates /var/lib/nfs/ (which no sync) and then checks
   to see if mountd is running.  If it is, it assume 'server' and
   waits a while for lockd to appear (both checks via portmap).
   Once lockd is running (or mountd was not), it sends out
   notifications.
  mountd checks if sm-notify has already run (via the /var/run file),
   and complains gently, maybe only if it is less than a few minutes
   before boot.  e.g.
    WARNING: during boot, mountd must be run before sm-notify!

  statd always runs sm-notify first and waits for it to exit, which
    it does once it has moved things aside and updated 'state'.
    One the first SM_MON call, statd call 'fsync' on 'state' and
    related directories, and writes the 'state' value to the
    kernel....  which is moments to late.  The kernel has already
    used it.  Maybe we need a call to nsm_monitor in nlmclnt_proc,
    and maybe _reclaim and _cancel too - not sure

  mount.nfs makes sure statd is running - we already have that.

  rpc.nfsd can complain if statd is not already running, or maybe
    even just start it.


That, I think, should enforce some of the ordering, and complain
if other ordering requirements aren't met.

And just for the record: my strongest argument for keeping them
separate is that statd (being network service) should only be started
if and when it is actually needed, while sm-notify should always be
run at boot in case it has some cleaning up to do.


Thanks,
NeilBrown
