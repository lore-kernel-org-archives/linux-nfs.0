Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60114 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728845AbeIGARq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Sep 2018 20:17:46 -0400
Date: Thu, 6 Sep 2018 15:40:48 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 10/10] nfsd: clients don't need to break their own
 delegations
Message-ID: <20180906194048.GE12881@fieldses.org>
References: <1521470194-24840-11-git-send-email-bfields@redhat.com>
 <1521470194-24840-1-git-send-email-bfields@redhat.com>
 <29167.1521552951@warthog.procyon.org.uk>
 <1521553578.10293.4.camel@primarydata.com>
 <20180320144928.GA4288@fieldses.org>
 <1521558822.15893.12.camel@primarydata.com>
 <20180320160257.GC4288@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180320160257.GC4288@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 20, 2018 at 12:02:57PM -0400, bfields@fieldses.org wrote:
> On Tue, Mar 20, 2018 at 03:13:47PM +0000, Trond Myklebust wrote:
> > Right now, the knfsd threads are regular kernel threads, with each
> > thread appearing to userspace to be a process in its own right.
> > Is there any reason why we could not assign them a group pid that would
> > allow the fl_nspid mechanism to work (i.e. set task->group_leader)?
> 
> Huh, OK, I hadn't thought about that.

Thinking about it: as far as I can tell that's not meant to be modified
on a running thread, so we need to create the thread the right way--all
the nfsd threads need to be children of the same thread.

Currently we're using kthead_create() which makes them all children of
kthreadd.

I spent a little time looking into forking threads from existing nfsd
threads and started to feel like I was duplicating a lot of kthread
code.

So now I wonder if it's possible to generalize kthreadd somehow.

--b.
