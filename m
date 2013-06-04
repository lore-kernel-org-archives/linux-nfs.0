Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009Ab3FDPQB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 11:16:01 -0400
Date: Tue, 4 Jun 2013 11:15:02 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        "Stefan (metze) Metzmacher" <metze@samba.org>, viro@zeniv.linux.org.uk,
        matthew@wil.cx, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        cluster-devel@redhat.com, sage@inktank.com,
        samba-technical@lists.samba.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        dhowells@redhat.com, smfrench@gmail.com, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org, akpm@linux-foundation.org,
        swhiteho@redhat.com
Subject: Re: [PATCH v1 11/11] locks: give the blocked_hash its own spinlock
Message-ID: <20130604111502.6231d010@corrin.poochiereds.net>
In-Reply-To: <20130604145322.GH2109@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
	<1370056054-25449-12-git-send-email-jlayton@redhat.com>
	<51ADF789.70906@samba.org>
	<20130604144640.GA7730@infradead.org>
	<20130604145322.GH2109@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 4 Jun 2013 10:53:22 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jun 04, 2013 at 07:46:40AM -0700, Christoph Hellwig wrote:
> > Having RCU for modification mostly workloads never is a good idea, so
> > I don't think it makes sense to mention it here.
> > 
> > If you care about the overhead it's worth trying to use per-cpu lists,
> > though.
> 
> Yes.  The lock and unlock could happen on different CPU's--but I think
> you can make the rule that the lock stays associated with the list it
> was first put on, and then it's correct in general and hopefully quick
> in the common case.
> 

It's important to distinguish between the blocked_list/hash and the
file_lock_list. Yes, they use the same embedded list_head or hlist_node
in the file_lock, but they have very different characteristics and use
cases.

In the testing I did, having a hashtable for the blocked locks helped a
lot more than a percpu list. The trick with deadlock detection is to
ensure that you don't spend a lot of time walking the lists. Since we
do deadlock detection frequently, we need to optimize for that case.

For the file_lock_list, it might make sense to have percpu hlists with
an lglock however. The thing to note here is that the file_lock_list is
almost never read. Only /proc/locks uses it, so anything we can do to
optimize the list manipulation is probably worth it.

All that said, I'm leery about changing too much of this code too fast.
It's pretty old and poorly understood, so I think we need to be
cautious and take an incremental approach to changing it.

-- 
Jeff Layton <jlayton@redhat.com>
