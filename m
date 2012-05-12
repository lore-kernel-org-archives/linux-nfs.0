Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54679 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215Ab2ELOQy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 May 2012 10:16:54 -0400
Date: Sat, 12 May 2012 10:16:53 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] NFSd laundromat containerization
Message-ID: <20120512141653.GA19757@fieldses.org>
References: <4FAD1934.8070908@parallels.com>
 <20120511135306.GA12795@fieldses.org>
 <4FAE2659.4090107@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FAE2659.4090107@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 12, 2012 at 12:59:05PM +0400, Stanislav Kinsbursky wrote:
> On 11.05.2012 17:53, bfields@fieldses.org wrote:
> >On Fri, May 11, 2012 at 05:50:44PM +0400, Stanislav Kinsbursky wrote:
> >>Hello.
> >>I'm currently looking on NFSd laundromat work, and it looks like
> >>have to be performed per networks namespace context.
> >>It's easy to make corresponding delayed work per network namespace
> >>and thus gain per-net data pointer in laundromat function.
> >>But here a problem appears: network namespace is required to skip
> >>clients from other network namespaces while iterating over global
> >>lists (client_lru and friends).
> >>I see two possible solutions:
> >>1) Make these list per network namespace context. In this case
> >>network namespace will not be required - per-net data will be
> >>enough.
> >>2) Put network namespace link on per-net data (this one is easier, but uglier).
> >
> >I'd rather there be as few shared data structures between network
> >namespaces as possible--I think that will simplify things.
> >
> >So, of those two choices, #1.
> >
> 
> Guys, I would like to discuss few ideas about caches and lists containerization.
> Currently, it look to me, that these hash tables:
> 
> reclaim_str, conf_id, conf_str, unconf_str, unconf_id, sessionid
> 
> and these lists:
> 
> client_lru, close_lru
> 
> have to be per net, while hash tables
> 
> file, ownerstr, lockowner_ino
> 
> and
> 
> del_recall_lru lists
> 
> have not, because they are about file system access.

Actually, ownerstr and lockowner_ino should also both be per-container.

So it's only file and del_recall_lru that should be global.  (And
del_recall_lru might work either way, actually.)

> If I'd containerize it this way, then looks like nfs4_lock_state()
> and nfs4_unlock_state() functions will protect only
> non-containerized data, while containerized data have to protected
> by some per-net lock.

Sounds about right.

--b.

> 
> How this approach looks to you?
> 
> 
> -- 
> Best regards,
> Stanislav Kinsbursky
