Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57256 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753044AbeD3Nlz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2018 09:41:55 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3UDfE9r034802
        for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2018 09:41:54 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2hp1vsxvmf-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2018 09:41:54 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Mon, 30 Apr 2018 09:41:53 -0400
Date: Mon, 30 Apr 2018 06:43:08 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Josh Triplett <josh@joshtriplett.org>
Cc: NeilBrown <neilb@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] rculist: add list_for_each_entry_from_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
References: <152506256513.7246.13171564155614823841.stgit@noble>
 <152506269061.7246.13075216914692813995.stgit@noble>
 <20180430052032.GA16963@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180430052032.GA16963@localhost>
Message-Id: <20180430134308.GT26088@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 29, 2018 at 10:20:33PM -0700, Josh Triplett wrote:
> On Mon, Apr 30, 2018 at 02:31:30PM +1000, NeilBrown wrote:
> > list_for_each_entry_from_rcu() is an RCU version of
> > list_for_each_entry_from().  It walks a linked list under rcu
> > protection, from a given start point.
> > 
> > It is similar to list_for_each_entry_continue_rcu() but starts *at*
> > the given position rather than *after* it.
> > 
> > Naturally, the start point must be known to be in the list.
> 
> I'd suggest giving an explicit advisory comment to clarify and suggest
> correct usage:
> 
> "This would typically require either that you obtained the node from a
> previous walk of the list in the same RCU read-side critical section, or
> that you held some sort of non-RCU reference (such as a reference count)
> to keep the node alive *and* in the list."
> 
> (Feel free to wordsmith the exact wording, but something like that seems
> like it would help people understand how to use this correctly, and make
> it less likely that they'd use it incorrectly.)

What Josh said!  Could you also contrast this with the existing
list_for_each_entry_continue_rcu() macro in the header comment as well
as in the commit log?

							Thanx, Paul

