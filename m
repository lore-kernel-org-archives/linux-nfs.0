Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51844 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728Ab2K0WJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 17:09:46 -0500
Date: Tue, 27 Nov 2012 17:09:39 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSd state: nfs4_lock_state() and nfs4_lock_state()
Message-ID: <20121127220939.GI27142@fieldses.org>
References: <50A622AE.3080809@parallels.com>
 <20121116165845.GA32183@fieldses.org>
 <50A9F03B.1010909@parallels.com>
 <20121119124618.GA30084@fieldses.org>
 <50AF5E7F.2010006@parallels.com>
 <20121126223639.GC18186@fieldses.org>
 <50B471B6.2010407@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50B471B6.2010407@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 27, 2012 at 11:54:30AM +0400, Stanislav Kinsbursky wrote:
> 27.11.2012 02:36, bfields@fieldses.org пишет:
> >On Fri, Nov 23, 2012 at 03:31:11PM +0400, Stanislav Kinsbursky wrote:
> >>19.11.2012 16:46, bfields@fieldses.org пишет:
> >>>On Mon, Nov 19, 2012 at 12:39:23PM +0400, Stanislav Kinsbursky wrote:
> >>>>16.11.2012 20:58, bfields@fieldses.org пишет:
> >>>>>
> >>>>>A patch follows: note it's a two-line patch, with 20 lines of changelog
> >>>>>showing that I looked at what state might be shared by other threads and
> >>>>>explaining why I think this is safe.
> >>>>>
> >>>>
> >>>>Acked-by: Stanislav Kinsburskiy <skinsbursky@parallels.com>
> >>>>
> >>>>>I think that's what we need to do: little patches that remove it from
> >>>>>one or another part of the code with careful explanation of why it
> >>>>>works.
> >>>>>
> >>>>
> >>>>Yes, thanks. I'll also try to simplify nfsd_open() by little patches.
> >>>>In general it looks like client_mutex protect two different things:
> >>>>open owner state (which is containerised already, actually) and
> >>>>files access.
> >>>>So, probably, this client mutex have to be converted into two:
> >>>>per-net one, which protects open owner state, and static one, which
> >>>>protects files operations.
> >>>>What do you think about it?
> >>>
> >>>That sounds right.
> >>>
> >>
> >>Looked into the code, and few more questions raised.
> >>So, currently, this mutex protects different NFS4 state structures and VFS file operations (like open, read, write, etc.).
> >>I would like this mutex to be converted into per-net one. Since NFS4
> >>state structures are per-net already (with my previous patch set),
> >>the only thing left is VFS operations.
> >>But do we really need to protect them somehow from concurrent access?
> >>I.e. do we have some RPCs, which does more that one file manipulation, but this manipulations sequence have to be "atomic" in NFSd terms?
> >
> >Probably not, but open is the most likely problem, as it does several
> >things which are not all atomic from the point of view of the vfs.  The
> >mutex can't prevent races between an nfs client and a local user, but it
> >can at least prevent races between nfs clients.
> >
> 
> Ok then.
> You said, that you are going to optimize open a bit?

It's on my todo list, but I'm not sure when it will be done.

> I think client_mutex containerization can be delayed for a while.

OK.--b.
