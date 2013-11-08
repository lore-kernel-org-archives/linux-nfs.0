Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757212Ab3KHPMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 10:12:36 -0500
Date: Fri, 8 Nov 2013 10:12:32 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Message-ID: <20131108101232.10d49851@tlielax.poochiereds.net>
In-Reply-To: <527CFC72.2030907@RedHat.com>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
	<A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>
	<527C07B4.800@RedHat.com>
	<44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
	<527CDBFC.3070903@RedHat.com>
	<20131108082202.4032f1a2@tlielax.poochiereds.net>
	<527CFC72.2030907@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 Nov 2013 10:00:02 -0500
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 08/11/13 08:22, Jeff Layton wrote:
> > On Fri, 08 Nov 2013 07:41:32 -0500
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >>
> >>
> >> On 07/11/13 18:05, Chuck Lever wrote:
> >>>
> >>> On Nov 7, 2013, at 1:35 PM, Steve Dickson <SteveD@redhat.com> wrote:
> >>>
> >>>> Hey mrchuck... 
> >>>>
> >>>> On 07/11/13 14:25, Chuck Lever wrote:
> >>>>> Hi Steve-
> >>>>>
> >>>>> On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:
> >>>>>
> >>>>>> This new module parameter makes the v4 client
> >>>>>> use the minimal authentication flavor (AUTH_UNIX)
> >>>>>> when establishing NFSV4 state and doing the
> >>>>>> pseudoroot lookup
> >>>>>
> >>>>> The patch description doesn't say, but is this change to work 
> >>>>> around the 15 second GSSD upcall timeout? 
> >>>> Yes. A 15 second delay on every mount due to security that
> >>>> nobody is requesting is just not good.. IMHO..
> >>>
> >>> One thing we haven't discussed is reducing the upcall timeout to 5 seconds or less, 
> >>> as a form of immediate relief.  15 seconds is arbitrary, and is onerous even when 
> >>> you expect the mount to work (ie why would it be good for any properly configured 
> >>> environment to take 15 seconds to establish a GSS context?).
> >>>
> >>> In other words, there are still cases where users wait 15 seconds unnecessarily, 
> >>> and not because of the use of krb5i for lease management.  Aren't those of concern?
> >> No. I think the concern here, at least my concern, is the lack of management.
> >> We are forcing admins to use krb5i in lease management when its not necessary
> >> and there is no way to turn it off.
> >>   
> > 
> > I don't think that's really the case. The idea was to have the client
> > attempt to use krb5i if it's available, and then to fall back to
> > AUTH_SYS if it isn't. This would be *absolutely* no big deal if the
> > GSSAPI upcall succeeded or failed immediately instead of requiring this
> > timeout when the daemon isn't running.
> What server makes krb5i available today in state setup and pseudoroot lookups?
> 

That I don't know...sorry...

> > 
> >>>
> >>>> Also running
> >>>> a security daemon for non-secure mounts just seems wrong to me.
> >>>
> >>> It seems wrong to me to keep auth_rpcgss loaded if no mounts use Kerberos security.  
> >>> What's the difference between that and running gssd all the time?
> >> You can say thing about %99 of all the modules load in a Fedora kernel today.
> >> lsmod | wc -l show there is 107 modules load on a f19 system. Do you think
> >> all those modules are used? Of course not, but they are not spewing 25
> >> log messages per mount or sucking up CPU cycles unnecessarily. 
> >>
> > 
> > rpc.gssd spends most of its time sleeping, unless there is
> > nfs mount or "real" gssapi activity. CPU cycles shouldn't be an issue.
> > The RSS for the process on my 64-bit box is ~2k so I wouldn't even be
> > concerned about memory usage. For comparison, we don't worry much about
> > running rpc.statd these days and it's of similar size and duty cycle.
> rpc.statd is needed by the V3 protocol to support file locking which
> is a bit more needed that a rpc.gssd to do unsecured mounts.
> 

Right, but we've defaulted to v4 for *years* now. Most people run statd
and don't actually use it. No one seems to get bent out of shape about
that though.

> > 
> > The log messages are another matter. rpc.gssd is just too chatty by
> > default. That's fixable, but it would mean that we'd need to tell
> > people to run it in verbose mode when tracking down problems instead of
> > assuming that all of those messages would go to the logs. That seems
> > like a reasonable thing to do anyway. Most people don't care about
> > rpc.gssd log messages once they have kerberized NFS working.
>
> So we should remove error and warning messages that in the
> pass help us debug very difficult code so we can run rpc.gssd
> just for normal unsecured mounts? 
> 

Yes. Because in the case where you don't have a keytab or a credcache,
failure is expected. There's no need to log messages due to those sorts
of problems. Once you have it working correctly, there's just no need to
keep logging that junk. Most of those log messages should only be
enabled when rpc.gssd is run with -v(vvv). Admins can (and often do)
run rpc.gssd in foreground with those flags while they sort through the
setup.

> My apologies... but that makes absolutely no sense to me. 
> 
> Let talk about scalability... Does anybody have idea what
> this needless upcall will cost on a client that does 
> a very large number of mounts all at once? 
> 

Virtually nothing -- a couple of pipe reads/writes.

> Please let me reiterate my point. The new securing of
> SETCLIENTIDs and pseudoroot lookups is good! I have
> no problem with the actual technology. What I'm having
> a problem with is I can not manage this new technology.
> 
> Could you image the push back there would be if, 
> back in the day when secure mounts became available, 
> we required *everyone* to use secure mounts. The 
> only way you could use NFS  was through a secure mount.
> 
> That's basically what we are doing today! We are requiring
> every mount to try a secure flavor that fails %100 time
> because there is no server support for this technology. 
> 
> Again its not the technology, its the management of the
> technology that this new module parameter address. All
> I'm looking for is switch that enables or disables 
> this new technology... 
> 

No one is requiring anyone to do anything. IMO, running rpc.gssd by
default is simply a reasonable workaround for this long delay in
mounting until we have a real solution for this problem.

I'd like to see us transition to a more sensible upcall in the future
that doesn't require this timeout, but we're not there yet. Once we
have that, we won't need to run rpc.gssd at all anymore.

FWIW, I'm perfectly happy do the work on such an upcall. I think
call_usermodehelper (or maybe keys API) makes a lot of sense for this.
The only real problem I can see with doing this today is the damnable
namespaces. The nfs client is currently net-namespacified, but running
something like call_usermodehelper sort of requires that you switch the
mnt namespace too.

-- 
Jeff Layton <jlayton@redhat.com>
