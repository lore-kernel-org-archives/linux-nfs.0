Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mslow2.mail.gandi.net ([217.70.178.242]:35764 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752063AbeD3Ftl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2018 01:49:41 -0400
Date: Sun, 29 Apr 2018 22:20:33 -0700
From: Josh Triplett <josh@joshtriplett.org>
To: NeilBrown <neilb@suse.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] rculist: add list_for_each_entry_from_rcu()
Message-ID: <20180430052032.GA16963@localhost>
References: <152506256513.7246.13171564155614823841.stgit@noble>
 <152506269061.7246.13075216914692813995.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <152506269061.7246.13075216914692813995.stgit@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 30, 2018 at 02:31:30PM +1000, NeilBrown wrote:
> list_for_each_entry_from_rcu() is an RCU version of
> list_for_each_entry_from().  It walks a linked list under rcu
> protection, from a given start point.
> 
> It is similar to list_for_each_entry_continue_rcu() but starts *at*
> the given position rather than *after* it.
> 
> Naturally, the start point must be known to be in the list.

I'd suggest giving an explicit advisory comment to clarify and suggest
correct usage:

"This would typically require either that you obtained the node from a
previous walk of the list in the same RCU read-side critical section, or
that you held some sort of non-RCU reference (such as a reference count)
to keep the node alive *and* in the list."

(Feel free to wordsmith the exact wording, but something like that seems
like it would help people understand how to use this correctly, and make
it less likely that they'd use it incorrectly.)
