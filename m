Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:58998 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932647Ab2J2Q2O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 12:28:14 -0400
Date: Mon, 29 Oct 2012 09:27:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Sasha Levin <levinsasha928@gmail.com>, tj@kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v7 09/16] SUNRPC/cache: use new hashtable implementation
Message-Id: <20121029092758.1ab87d79.akpm@linux-foundation.org>
In-Reply-To: <CA+55aFzO8DJJP3HBfgqXFac9r3=bYK+_nYe4cuXiNFg-623s6w@mail.gmail.com>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
	<1351450948-15618-9-git-send-email-levinsasha928@gmail.com>
	<20121029124229.GC11733@Krystal>
	<CA+55aFzO8DJJP3HBfgqXFac9r3=bYK+_nYe4cuXiNFg-623s6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 29 Oct 2012 07:49:42 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Because there's no reason to believe that '9' is in any way a worse
> random number than something page-shift-related, is there?

9 is much better than PAGE_SHIFT.  PAGE_SIZE can vary by a factor of
16, depending on config.

Everyone thinks 4k, and tests only for that.  There's potential for
very large performance and behavior changes when their code gets run
on a 64k PAGE_SIZE machine.
