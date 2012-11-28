Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55259 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755392Ab2K1O5i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 09:57:38 -0500
Date: Wed, 28 Nov 2012 09:57:38 -0500
To: Andrei Warkentin <awarkentin@vmware.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Race between NFS server thread increase / decrease
Message-ID: <20121128145738.GD11651@fieldses.org>
References: <477254919.31693823.1353963259597.JavaMail.root@vmware.com>
 <864189844.31754280.1353966597599.JavaMail.root@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <864189844.31754280.1353966597599.JavaMail.root@vmware.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 01:49:57PM -0800, Andrei Warkentin wrote:
> Hi NFSD developers,
> 
> I've found what I think is an interesting problem that occurs on single-CPU machines as far as I can tell.
> 
> Basically the following snippet will occasionally loop forever printing that one thread is still running. Further
> attempts to run "/usr/sbin/rpc.nfsd 0" don't help.
> 
> /usr/sbin/rpc.nfsd 1
> /usr/sbin/rpc.nfsd 0
> while [ ! $[`cat /proc/fs/nfsd/threads`] -eq 0 ]; do
>         echo $[`cat /proc/fs/nfsd/threads`] still running
>         sleep .1
> done
> 
> I've not looked a whole lot at it. It appears that although the paths calling svc_set_num_threads synchronize on nfsd_mutex, the code doesn't seem to try waiting on the number of threads to reach the desired count.

Yeah, I guess it just signals and returns, I agree that's not ideal.

Though in your case fixing that may just mean the "rpc.nfsd 0" would
hang.

> What do you guys think?

That is odd.  I'm not sure to suggest without spending a bunch of time
on it.

Presumably ps will still show an nfsd thread running?

Might be interesting to see its stack (cat /proc/<pid>/stack) or look at
a full sysrq-t dump (sysrq-t, then check the logs).

Is it stuck spinning in some kind of loop?  (E.g. does "top" show
anything interesting?)

If none of that provides any hints, I dunno, my caveman approach would
be to just stare really hard and the relevant code and start sprinkling
printk's around as necessary.

--b.

> 
> Thanks.
> 
> A
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
