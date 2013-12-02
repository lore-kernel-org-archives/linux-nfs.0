Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:47123 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3LBP51 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 10:57:27 -0500
Date: Mon, 2 Dec 2013 15:57:22 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Torvalds Linus <torvalds@linux-foundation.org>,
        Eric Biederman <ebiederm@xmission.com>
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
Message-ID: <20131202155722.GE10323@ZenIV.linux.org.uk>
References: <20131201131441.790963326@bombadil.infradead.org>
 <20131201181329.GC10323@ZenIV.linux.org.uk>
 <20131202081233.GA6953@infradead.org>
 <3C65EB4C-6592-44F8-B08D-E5A9EFD6C8C6@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3C65EB4C-6592-44F8-B08D-E5A9EFD6C8C6@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 08:44:25AM -0500, Trond Myklebust wrote:

> > I'll have to let the net namespace folks chime in for that, as far as
> > I'm concerned it's a featured better config'ed off.  If they can't come
> > up with anything better the procfs hack above would be it.
> 
> The lifetime of the kernel mount only needs to match that of the rpc_client, since each rpc_client is associated to a single net namespace, and each net namespace is in a 1-1 relationship with an rpc_pipefs super block.
> 
> IOW: move the kernel mount/umount back to the rpc_client create/destroy methods and all should be well.

Hmm...  I'm looking through rpc_pipe.c and there are some fun issues in there:
	* ->kill_sb() *is* called after rpc_fill_super() failures.  It's
not ->put_super() (and even ->put_super() would've been called for failures
past setting ->s_root).  With ->s_fs_info set only on success, it means
that rpc_kill_sb() will just oops after such failure exits.
	* just what is
        if (sn->pipefs_sb != sb) {
                mutex_unlock(&sn->pipefs_sb_lock);
                goto out;
        }
        sn->pipefs_sb = NULL;
about?  In which scenario is it not equal to ->pipefs_sb?  When said
->pipefs_sb is NULL?  But that, AFAICS, can happen only on cleanup after
failing rpc_fill_super(), in which case we won't get that sn thing in
the first place (in fact, we'll oops trying to get it).

Trond, am I right interpreting you as "that filesystem has non-empty
contents only when there is at least one rpc_client in that netns;
after rpc_client removal there won't be any accesses to data structures
associated with it (due to rpc_close_pipes() and friends, presumably),
so there won't be any need to keep netns alive after that"?

If so and if rpc_client really can't outlive netns, then yes, having each 
of them hold an internal vfsmount reference pinning rpc_pipefs down would
suffice.
