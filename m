Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239Ab2EONzT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 09:55:19 -0400
Date: Tue, 15 May 2012 09:55:15 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] NFSd laundromat containerization
Message-ID: <20120515095515.64bcfa32@tlielax.poochiereds.net>
In-Reply-To: <20120515094008.698e538b@tlielax.poochiereds.net>
References: <4FAD1934.8070908@parallels.com>
	<20120511135306.GA12795@fieldses.org>
	<4FAE2659.4090107@parallels.com>
	<20120512141653.GA19757@fieldses.org>
	<4FB0C9A1.6080406@parallels.com>
	<20120515094008.698e538b@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 May 2012 09:40:08 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 14 May 2012 13:00:17 +0400
> Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
> 
> > On 12.05.2012 18:16, bfields@fieldses.org wrote:
> > > On Sat, May 12, 2012 at 12:59:05PM +0400, Stanislav Kinsbursky wrote:
> > >> On 11.05.2012 17:53, bfields@fieldses.org wrote:
> > >>> On Fri, May 11, 2012 at 05:50:44PM +0400, Stanislav Kinsbursky wrote:
> > >>>> Hello.
> > >>>> I'm currently looking on NFSd laundromat work, and it looks like
> > >>>> have to be performed per networks namespace context.
> > >>>> It's easy to make corresponding delayed work per network namespace
> > >>>> and thus gain per-net data pointer in laundromat function.
> > >>>> But here a problem appears: network namespace is required to skip
> > >>>> clients from other network namespaces while iterating over global
> > >>>> lists (client_lru and friends).
> > >>>> I see two possible solutions:
> > >>>> 1) Make these list per network namespace context. In this case
> > >>>> network namespace will not be required - per-net data will be
> > >>>> enough.
> > >>>> 2) Put network namespace link on per-net data (this one is easier, but uglier).
> > >>>
> > >>> I'd rather there be as few shared data structures between network
> > >>> namespaces as possible--I think that will simplify things.
> > >>>
> > >>> So, of those two choices, #1.
> > >>>
> > >>
> > >> Guys, I would like to discuss few ideas about caches and lists containerization.
> > >> Currently, it look to me, that these hash tables:
> > >>
> > >> reclaim_str, conf_id, conf_str, unconf_str, unconf_id, sessionid
> > >>
> > >> and these lists:
> > >>
> > >> client_lru, close_lru
> > >>
> > >> have to be per net, while hash tables
> > >>
> > >> file, ownerstr, lockowner_ino
> > >>
> > >> and
> > >>
> > >> del_recall_lru lists
> > >>
> > >> have not, because they are about file system access.
> > >
> > > Actually, ownerstr and lockowner_ino should also both be per-container.
> > >
> > > So it's only file and del_recall_lru that should be global.  (And
> > > del_recall_lru might work either way, actually.)
> > >
> > >> If I'd containerize it this way, then looks like nfs4_lock_state()
> > >> and nfs4_unlock_state() functions will protect only
> > >> non-containerized data, while containerized data have to protected
> > >> by some per-net lock.
> > >
> > > Sounds about right.
> > >
> > 
> > Bruce, Jeff, I've implemented these per-net hashes and lists (file hash and 
> > del_recall_lru remains global).
> > But now I'm confused with locking.
> > 
> > For example, let's consider file hash and del_recall_lru lists.
> > It looks like they are protected by recall_lock. But in 
> > nfsd_forget_delegations() this lock is not taken. Is it a bug?
> 
> It looks like a bug to me. If another thread is modifying the
> file_hashtbl while you're calling nfsd_forget_delegations, then you
> could oops here.
> 
> Perhaps we only ever modify that table while holding the state mutex in
> which case the code won't oops, but the recall lock seems rather
> superfluous at that point.
> 
> I'd have to unwind the locking and see...
> 
> > If yes and recall_lock is used for file hash protection, then why do we need to 
> > protect nfsd_process_n_delegations() by nfs4_un/lock_state() calls?
> > 
> > Actually, the problem I'm trying to solve is to replace global client_lock by 
> > per-net one where possible. But I don't clearly understand, what it protects.
> > 
> > Could you, guys, clarify the state locking to me.
> > 
> 
> I wish I could -- I'm still wrapping my brain around it too...
> 

Ok, yeah that is a bug AFAICT.

You really need to hold the recall_lock while walking that list, but
that makes unhash_delegation tricky -- it can call fput and iput which
can block (right?).

One possibility is to just have the loop move the entries to a private
list. Then you can walk that list w/o holding the lock and do
deleg_func on each entry.

-- 
Jeff Layton <jlayton@redhat.com>
