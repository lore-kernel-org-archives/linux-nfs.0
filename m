Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:51061 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab3LCCLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 21:11:06 -0500
Date: Tue, 3 Dec 2013 02:11:03 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Eric Biederman <ebiederm@xmission.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: [RFC] alloc_pid() breakage
Message-ID: <20131203021103.GH10323@ZenIV.linux.org.uk>
References: <20131201131441.790963326@bombadil.infradead.org>
 <20131201181329.GC10323@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131201181329.GC10323@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 01, 2013 at 06:13:29PM +0000, Al Viro wrote:
 
> AFAICS, pid_ns gets internal procfs instance and it pins the sucker down.
> Which would cause exact same problems, obviously.  The trick done there
> is more or less to introduce a "being shut down" state of pid_ns - from
> the moment when we don't have any pids in it to actual destruction.
> Entering that state schedules (yes, it is async and yes, it is ugly)
> dropping the internal procfs vfsmount.
> 
> Additional headache, AFAICS, comes from /proc/self/ns/pid - it can be
> opened, passed to somebody in ancestor pidns and then fed by it to
> setns(2).  After that fork() by that somebody will trigger alloc_pid() in
> that pid_ns.  What happens if it comes just before the (already scheduled)
> pid_ns_release_proc()?  AFAICS, nothing good - there's no protection
> against leaks, access to freed vfsmount, double-mntput, etc.  Eric, am
> I missing something subtle and relevant in that code?

Egads...  I think I see what's going on, but it's convoluted as hell -
you rely on 1 not getting returned more than once by alloc_pidmap(), even
after having been freed, so this
        if (unlikely(is_child_reaper(pid))) {
                if (pid_ns_prepare_proc(ns))
                        goto out_free;
        }
is essentially "on the first call of alloc_pid() for given pidns".  And
upper bit in ->nr_hashed acts as "it's not in rundown state".

OK, so... what happens if I do unshare(CLONE_NEWPID) and the first fork()
attempt fails (e.g. due to failure to allocate a map page when allocating
a number in parent pidns, or OOM-induced failure to mount procfs, whatever).
Sure, that fork() has failed.  No pid had been allocated, thus no free_pid()
calls made.  After a while the memory becomes less tight and the same process
tries to fork() again.  What happens then?  pidns with processes in it,
but no reaper and NULL ->proc_mnt?  sysctl(2) called in it won't be happy;
neither will exit(2), actually, since it'll hit proc_flush_task_mnt() and
oops on trying to evaluate ->proc_mnt->mnt_root...

Another question: can free_pid() end up scheduling ->proc_work for anything
other than the last level?  After all, reaper in parent pidns couldn't have
gotten through the zap_pid_ns_process() yet, let alone getting to its
free_pid(), right?
