From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] [PATCH 1/1] nfs41: resolve some race conditions with
 queued SEQUENCE operations when unmounting
Date: Wed, 14 Oct 2009 18:18:33 -0400
Message-ID: <1255558713.6308.44.camel@heimdal.trondhjem.org>
References: <1255561029-2925-1-git-send-email-batsakis@netapp.com>
	 <1255555809.6308.34.camel@heimdal.trondhjem.org>
	 <5e24e8930910141450h11e677bbr17ebe3441a8742d8@mail.gmail.com>
	 <1255557198.6308.36.camel@heimdal.trondhjem.org>
	 <1255557476.6308.39.camel@heimdal.trondhjem.org>
	 <5e24e8930910141509j3fad98afr66e25c465ced1e42@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:58597 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762078AbZJNWTM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 18:19:12 -0400
In-Reply-To: <5e24e8930910141509j3fad98afr66e25c465ced1e42-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-10-14 at 15:09 -0700, Alexandros Batsakis wrote:
> On Wed, Oct 14, 2009 at 2:57 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Wed, 2009-10-14 at 17:53 -0400, Trond Myklebust wrote:
> >> On Wed, 2009-10-14 at 14:50 -0700, Alexandros Batsakis wrote:
> >> > a) nfs41_sequence_done() called after destroy_session() that leads to
> >> > a NULL pointer dereference
> >> > b) a BADSESSION reply to a sequence operation triggers a
> >> > reset_session() at the same time with destroy_session() (called by
> >> > umount) that leads to another NULL pointer dereference.
> >>
> >> This would mean that nfs41_sequence_done is being called _after_ the
> >> nfs_client (and hence the session) has been destroyed. That sounds like
> >> the real bug that needs to be fixed.
> >
> > Correction: it means that nfs41_sequence_done is being called after the
> > superblock that "owns" those rpc calls has been destroyed. (Which is a
> > bug... :-))
> >
> 
> Agreed. FWIW and from a conceptual point of view, the patch above is a
> bit orthogonal to that as it deals with the problem within the session
> scope. It treats the umount just as a session destroyer that happens
> to always destroy the super-block in the current
> one-session-per-client implementation. The latter may change, but the
> patch will remain relevant (obviously with few adjustments).

I completely disagree. If your code may end up starting the state
manager after the nfs_client is destroyed, then you _will_ corrupt
significant swathes of memory.

> Anyway, as long as we fix the bug I am happy :)

I don't think you have...

Trond

