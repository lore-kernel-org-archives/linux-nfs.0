Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:62160 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbaDPFNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 01:13:48 -0400
Message-ID: <1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH 10/19] NET: set PF_FSTRANS while holding sk_lock
From: Eric Dumazet <eric.dumazet@gmail.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com, netdev@vger.kernel.org
Date: Tue, 15 Apr 2014 22:13:46 -0700
In-Reply-To: <20140416040336.10604.96000.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	 <20140416040336.10604.96000.stgit@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-04-16 at 14:03 +1000, NeilBrown wrote:
> sk_lock can be taken while reclaiming memory (in nfsd for loop-back
> NFS mounts, and presumably in nfs), and memory can be allocated while
> holding sk_lock, at least via:
> 
>  inet_listen -> inet_csk_listen_start ->reqsk_queue_alloc
> 
> So to avoid deadlocks, always set PF_FSTRANS while holding sk_lock.
> 
> This deadlock was found by lockdep.

Wow, this is adding expensive stuff in fast path, only for nfsd :(

BTW, why should the current->flags should be saved on a socket field,
and not a current->save_flags. This really looks a thread property, not
a socket one.

Why nfsd could not have PF_FSTRANS in its current->flags ?

For applications handling millions of sockets, this makes a difference.


