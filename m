Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0122.hostedemail.com ([216.40.44.122]:55620 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932617AbcF3QYO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2016 12:24:14 -0400
Date: Thu, 30 Jun 2016 12:24:10 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
        "Linux Network Devel Mailing List" <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port
 (left over from xs_bind() ))
Message-ID: <20160630122410.1022ea37@gandalf.local.home>
In-Reply-To: <20160630112341.5ab5a821@gandalf.local.home>
References: <20160630085950.61e5c7e0@gandalf.local.home>
	<C44AFFBB-EF40-4B22-8B45-7817EB7276E3@primarydata.com>
	<20160630112341.5ab5a821@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 30 Jun 2016 11:23:41 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:


> I can add more trace_printk()s if it would help.

I added a trace_printk() in inet_bind_bucket_destroy() to print out
some information on the socket used by xs_bind(), and it shows that the
bind destroy is called, but the list is not empty.



/*
 * Caller must hold hashbucket lock for this tb with local BH disabled
 */
void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket *tb)
{
	if (!current->mm && xs_port == tb->port) {
		trace_printk("destroy %d empty=%d %p\n",
			     tb->port, hlist_empty(&tb->owners), tb);
		trace_dump_stack(1);
	}
	if (hlist_empty(&tb->owners)) {
		__hlist_del(&tb->node);
		kmem_cache_free(cachep, tb);
	}
}

I created "xs_port" to hold the port of the variable used by xs_bind,
and when it is called, the hlist_empty(&tb->owners) returns false.

I'll add more trace_printks to find out where those owners are being
added.

-- Steve
