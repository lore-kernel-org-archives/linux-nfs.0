From: Philippe Troin <phil@fifi.org>
Subject: Re: [NFS client] NFS locks not released on abnormal process termination
Date: 08 Dec 2003 09:32:05 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <877k17rzai.fsf@ceramic.fifi.org>
References: <20031208033933.16136.qmail@web20024.mail.yahoo.com>
	<shszne3risb.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kenny Simpson <theonetruekenny@yahoo.com>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shszne3risb.fsf@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> >>>>> " " == Kenny Simpson <theonetruekenny@yahoo.com> writes:
> 
>      > So, this patch has not found its way into any kernel yet?  Is
>      > there anyone actively persuing this bug?
> 
> Feel free. There are only so many hours in a day, and right now
> mine are pretty much overbooked with NFSv4 stuff...

Please note that this fix only mitigates the bug: it can still occur,
but much less frequently. Before this patch, nfsd would loose track of
the lock (see the enclosed program at the beginning of the thread)
after a few (<5) kills. With the patch, it takes sometimes as many as
300~500 kills before the bugs manifests itself.

Trond, do you think I should push the patch to Marcelo, or should I
wait for a better fix? I don't think Marcelo would accept a partial
fix. I would try to fix it myself, but I have no clue on the inner
workings of lockd/nfsd.

Phil.
