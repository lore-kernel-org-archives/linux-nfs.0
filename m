Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57042 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192Ab2HCJr4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Aug 2012 05:47:56 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAJ75kXa9PRJMHXfTHGLxnXUAMwnA9RD5G+cjHnOdk8SE_hbsZQ@mail.gmail.com>
References: <CAJ75kXa9PRJMHXfTHGLxnXUAMwnA9RD5G+cjHnOdk8SE_hbsZQ@mail.gmail.com>
To: William Dauchy <wdauchy@gmail.com>
Cc: dhowells@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: nfs_idmap_legacy_upcall
Date: Fri, 03 Aug 2012 10:47:49 +0100
Message-ID: <866.1343987269@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

William Dauchy <wdauchy@gmail.com> wrote:

> I'm getting a trace on nfs_idmap_legacy_upcall with a 3.4.7 amd64 kernel.
> This nfs patch was also applied:
> a427b9e (trond tree) NFS: Fix a number of bugs in the idmapper
> Any thoughts?

I'm afraid I'm not going to be able to do a lot with this until the 13th as
I'm about to go on holiday.  If it is still a problem when I get back, I'll
look at it then.

David
