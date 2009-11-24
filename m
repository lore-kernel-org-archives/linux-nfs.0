From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Tue, 24 Nov 2009 17:54:53 -0500
Message-ID: <20091124225453.GC32242@fieldses.org>
References: <19211.7054.291514.185591@notabene.brown> <4B0BEDDB.1010203@RedHat.com> <20091124205616.GB29856@fieldses.org> <20091125085122.316f4eb3@notabene.brown> <4B0C5705.6030608@redhat.com> <20091125092227.77735d5a@notabene.brown> <4B0C5E48.8020600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58471 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934154AbZKXWyK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 17:54:10 -0500
In-Reply-To: <4B0C5E48.8020600@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2009 at 05:29:28PM -0500, Peter Staubach wrote:
> Neil Brown wrote:
> > On Tue, 24 Nov 2009 16:58:29 -0500
> > Peter Staubach <staubach@redhat.com> wrote:
> > 
> >> I think that we might be better off in the long run by taking a
> >> step back and getting all of the plumbing right, instead of
> >> cluttering up things to have knowledge which they have no
> >> business knowing or worrying about.
> > 
> > In principle, I completely agree.
> > 
> > 
> >> If the NFSv4 server gets a request which involves the root file
> >> handle and one has not been defined, then it should return the
> >> error that is defined by the protocol.  What the client chooses
> >> to do with the error is up to it.
> > 
> > There is no error for "root file handle has not been defined".
> > 
> > The only errors available for PUTROOTFH are:
> >  NFS4ERR_RESOURCE - which means "I'm exchausted after all the other
> >                     work you made me do" and shouldn't be returned for
> >                     the first op in a compound (that is an implied
> >                     restriction, not explicit).
> >  NFS4ERR_SERVERFAULT which means something strange went wrong.  This is
> >                     probably the closest, hence Bruce's recent patch to
> >                     use this error code.
> >  NFS4ERR_WRONGSEC   which means the security mechanism used by the
> >                     client isn't acceptable to the server.  This is
> >                     certainly not usable in this context.
> > 
> > So NFS4ERR_SERVERFAULT would be OK simply because it is a wildcard.
> > But RPC_PROG_MISMATCH, which means "I don't support that version of the
> > protocol" would also be correct in this case and it trivial for the
> > client to interpret.
> > 
> 
> Well, to the last section, that is an RPC error and not an
> NFS error.  The RPC error, VERSMISMATCH, might be close, but
> once again, is an RPC error and not an NFS error.

We certainly don't want to modify the putrootfh code to return
prog_mismatch.  First, it'd be annoying to figure out how to return an
rpc error at that point.  Second, it looks odd to the client, which may
have already sent other NFSv4 rpc's without trouble, and may have
trouble handling the error at this point (it would be within its rights
to assume we do support v4 if v4 NULL succeeds).  And third, because we
already have a simple established way to return prog_mismatch: just
start rpc.nfsd with -N 4.

> Doing something better is tough because of the way that exports
> and the NFS service are managed as distinct things.  Perhaps if
> the NFS service could detect that there were no NFSv4 exports,
> then it could decline to register the NFSv4 service.  Then, some
> of the RPC errors would make sense.
> 
> The layering in the current implementations seems to make things
> more difficult than it does make them easy.  Just my opinion.

You'd have to do an upcall to mountd to find out if there's an fsid=0
export before accepting any rpc's.  Sounds awkward.  It'd be easier if
we had an interface that allowed us to tell the server on NFS startup
whether there's a pseudoroot.  But we do: /proc/net/nfsd/versions.  And
if userspace is claiming to support v4 and then denying knowledge of any
pseudoroot in the mountd upcalls, then it's buggy.

(But, OK, agreed, we may just have to deal with the fact that lots of
servers are already configured that way and work around it on the
client.)

--b.
