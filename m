From: Andi Kleen <ak@suse.de>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Fri, 20 Sep 2002 04:06:19 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020920040619.A30304@wotan.suse.de>
References: <p73lm5xtqyv.fsf@oldwotan.suse.de> <3D8A754E.5BA2E28D@digeo.com> <20020920032346.A22949@wotan.suse.de> <20020919.182739.48496975.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, akpm@digeo.com, taka@valinux.co.jp,
	alan@lxorguk.ukuu.org.uk, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020919.182739.48496975.davem@redhat.com>
List-ID: <nfs.lists.sourceforge.net>

> See "montdq/movnti", the latter of which even works on register
> registers.  Ben LaHaise pointed this out to me earlier today.

The issue is that you really want to do prefetching in these loops
(waiting for the hardware prefetch is too slow because it needs several
cache misses to trigger) so for cache hints on reading only prefetch
instructions are interesting.

-Andi
