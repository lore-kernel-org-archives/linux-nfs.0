Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752110AbcLIWnz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Dec 2016 17:43:55 -0500
Date: Fri, 9 Dec 2016 17:43:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
Message-ID: <20161209224349.GD13651@parsley.fieldses.org>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <148065110833.28046.2561331715736018574.stgit@noble>
 <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com>
 <87r35k4rcr.fsf@notabene.neil.brown.name>
 <35ca5ad2-39db-a46b-13b2-a2e5128793a0@RedHat.com>
 <20161207180843.GA20626@parsley.fieldses.org>
 <877f7bs55d.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <877f7bs55d.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2016 at 10:14:54AM +1100, NeilBrown wrote:
> On Thu, Dec 08 2016, "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > On Wed, Dec 07, 2016 at 09:44:25AM -0500, Steve Dickson wrote:
> >> > 
> >> > I do wonder if this is ever valid though.  Why do we allow minor
> >> > versions to be enabled/disabled?
> >> IDK... I think Trond did this... you know...
> >> when in doubt... blame Trond! 8-) 
> >
> > Or Benny, 8daf220a6a83 "nfsd41: control nfsv4.1 svc via
> > /proc/fs/nfsd/versions".
> >
> >> > Does it make any sense to enable a non-contiguous set of minor versions?
> >> I don't think so... Talk about handing people rope! ;-)
> >
> > I can't think of a reason either.
> >
> >> > Should we just have a maximum NFSv4 minor version?
> >> Maybe.. 
> >
> > If you do that then I'd allow a minimum too.
> 
> Why?  I'm trying to understand why you would ever want to turn disable a
> particular minor version.  I could equally well ask myself "why specify
> a maximum"...

In the past setting a default maximum that's lower than the maximum
supported by the code has been a way to make new features available for
testers and early adopters while keeping other users safe.

For a minimum--I think "1" would be the most likely minimum, just
because there were some major changes made between 4.0 and 4.1, and
people might eventually want to enforce a policy of supporting only
versions >=4.1 in their environements.

And eventually, I don't know, maybe you really don't want clients
mounting unless they support labeled NFS, or something?  Though you
can't really force them to use new features.  I haven't really thought
it through.

> Benny's patch only suggests that it removes the need for
> CONFIG_NFSD_V4_1, but why was that needed?
> Maybe it is just to disable buggy code if some version is found to have
> an inconvenient bug?  The client, by default, tries 4.2, then 4.1, then
> 4.0.  Older clients might start elsewhere.  So just disabling unreliable
> versions individually does seem to make sense.
> 
> I note that Benny's original patch disabled v4.1 by default, and
> required it to be explicitly enabled.  The current kernel enables all by
> default, and requires them be explicitly disabled is required.
> My current nfs.conf code will disabled unwanted minor versions, but not
> enable any that are already disabled ... I guess I could fix that.

I think what that means is that the defaults are determined by the
kernel version you're running as opposed to by userspace.

The main reason for disabling minor versions has been immature code in
higher versions, and in that case I think it makes sense for the kernel
to provide the default: if you don't have a particular preference, I
think the choice of whether to run 4.1 or 4.0 probably depends on how
new your kernel is.

--b.

> .... it is a shame that we can only enable/disable minor versions
> when there are no nfsd threads running.  The justification for
> failing if nfsd is active is fairly lame, and only applies
> to major versions.  If minor versions could be changed at any time,
> then it could be a simple function of rpc.nfsd, and the config
> file would never need to enable things, only disable them.
> 
> Is there any other reason to disable minor versions, other than to avoid
> buggy code (either in server or client)??
> 
> 
> Actually.... I have a related question that I keep meaning to ask, but
> haven't.
> 
> What are the circumstances where NFSv3 should be preferred over NFSv4
> (assuming up-to-date kernels on server and client)?
> 
> I can think of:
>  - NFSv3 is safer if you might need to support loop-back mounts
>    as I don't think NFSv4 state management can reliably make forward
>    progress against memory pressure.  In particular, creating the
>    state-manager thread can deadlock waiting for an NFS write.
> 
>  - If you want fast-failover from one server to another,
>    NFSv3 is probably faster as it only imposes the grace-time on
>    lock requests.  NFSv4 imposes it on OPEN and so READ/WRITE
>    as well.
> 
>  - NFSv3 is preferred if (for some weird reason) you need
>    to use UDP.
> 
> Are there any others?  Are there any similar reasons to prefer a smaller
> NFSv4 minor version over a larger one?
> 
> Thanks,
> NeilBrown
> 
> >
> > --b.
> >
> >> > I was trying to duplicate the current functionality as closely as
> >> > convenient.  That might not be best in this case.
> >> You did a good job... this is definitely a nit.
> >> 
> >> steved.
> >> 


