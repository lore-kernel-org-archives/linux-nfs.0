Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40838 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934104AbcKJQf4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 11:35:56 -0500
Date: Thu, 10 Nov 2016 11:35:53 -0500
To: NeilBrown <neilb@suse.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question about nfsdcltrack --storagedir
Message-ID: <20161110163553.GA16125@fieldses.org>
References: <87k2cdmi26.fsf@notabene.neil.brown.name>
 <1478692626.2394.9.camel@redhat.com>
 <877f8c9pku.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <877f8c9pku.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 10, 2016 at 10:54:41AM +1100, NeilBrown wrote:
> On Wed, Nov 09 2016, Jeff Layton wrote:
> 
> > On Wed, 2016-11-09 at 14:46 +1100, NeilBrown wrote:
> >> Hi,
> >>  I notice that nfsdcltrack has a "--storagedir" option.
> >>  I wonder how this can be used, given the nfsdcltrack is only(?) called
> >>  from the kernel and there is no(?) mechanism to pass extra options.
> >> 
> >>  In a clustered-server context it would make sense(?) to share the
> >>  database between cluster nodes and it is easiest to do this if the
> >>  file in a separate filesystem (mounted as part of fail-over) rather
> >>  than in /var.
> >>  This can(?) be achieved using a symlink, but rpm likes to remove
> >>  symlinks to non-existent locations.
> >> 
> >>  With NFSv3 the equivalent is the state files maintained by statd, and
> >>  these can be relocated by passing the -P option to rpc.statd.
> >>  How does one do a similar thing for NFSv4???
> >> 
> >> 
> >
> > Ahh, I added that option mostly for when I was testing it. I did a lot
> > of the earlier testing running it by hand, and --storagedir let me use a
> > different directory for the db. I did have a vague idea that we might
> > use it in the situation you describe, but I never wired that up as I
> > didn't have a real need for it.
> >
> > We could add a new module parm that would set that option when the
> > kernel does its callout, or allow passing the storagedir by environment
> > variable.
> >
> > What would make the most sense from a usability standpoint?
> 
> Maybe a config file in /etc/ which nfsdcltrack reads on start-up?
> Though in some ways I'd rather that instead of running a program, the
> kernel sent a message to user-space.  Possibly a u-event?
> Then existing configuration mechanisms could be used to choose a program
> and a context for it to run in.
> I wonder if u-events handle namespaces at all.
> 
> This came up because a customer was symlinking all of /var/lib/nfs to
> shared storage (and lost their symlink thanks to rpm).  That isn't a
> solution that I really like, and it led me to reflect on other things in
> /var/lib/nfs.
> 
> etab - holds a normalized copy of /etc/exports, plus ad hoc changes.
>        It would like in /run/nfs if we built this today
> export-lock - lockfile to protect changes to above. Would also be
>        in /run if we built it today. (I wonder why that doesn't
>        use .etab.lock, which is already used for locking)
> state, sm, sm.bak - statd state files.  These belong in /var/lib/nfs
>        but are easily relocated with args to rpc.statd and sm-notify.
> v4recovery - the NFSv4 version of above
> xtab - this hasn't been needed since we gained /proc/fs/nfs/exports
>        It is just a record of what should be in the kernel
>        We should remove this.  I'll make a patch.
> rmtab - this hasn't been needed since the "new cache" and the
>        up-call mechanism were created.  It might be still used
>        to respond to "showmount" commands, but that was never reliable.
>        If we keep it, it should probably move to /run.
>        But what do people think if finally discarding the old
>        (non-new_cache) code and using that as an excuse to increment
>        the major version number of nfs-utils?

Looking at the history....  Looks like that went into 2.5.42 in late
2002.  In distro terms, first distros to support the new interface
include RHEL4, Debian 3.1/Sarge, Suse 9.

No comment on the other stuff, just wanted to check that as I'm inclined
to extreme conservatism on backwards compatibility.  But, yeah, I guess
that'd be OK.

--b.

> 
> rpc_pipefs - mountpoint of NFS upcall filesystem.  This was another
>        source of problems when /var/lib/nfs is a symlink elsewhere.
>        It isn't nice to mount this filesystem on that shared storage.
>        While programs that access this can be told to use an alternate
>        directory, it is hard to tell systemd's unit files to mount
>        it somewhere special (previously an init script would just
>        mount it wherever the config file said)
>        I note that Debian mounts this at /run/rpc_pipefs.
>        That seems like a really good idea. What do people think of
>        making this the "official" mount point?
> 
> If we moved some things to /run and removed others, it would just leave
> state,sm,sm.bak and v4recovery in /var/lib/nfs.  That is all the same
> type of data, which is nice.
> 
> So there are lots of things we could do, but at a minimum -
> /etc/nfsdcltrack.conf ??
> 
> Thanks,
> NeilBrown


