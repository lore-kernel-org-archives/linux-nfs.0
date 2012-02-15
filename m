Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42433 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543Ab2BOAxT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 19:53:19 -0500
Date: Tue, 14 Feb 2012 19:53:15 -0500
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Vitaliy Gusev <gusev.vitaliy@nexenta.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at
 nfs4_init_slot_table()
Message-ID: <20120215005315.GA9018@fieldses.org>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1329259606.11759.15.camel@lade.trondhjem.org>
 <4F3AFD84.3020709@nexenta.com>
 <1329266587.28837.4.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1329266587.28837.4.camel@lade.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 15, 2012 at 12:43:08AM +0000, Myklebust, Trond wrote:
> Then we have a problem. The zero initialisation is already in use out
> there in both commercial and non-commercial versions of Linux. It is too
> late to change that now.
> 
> Furthermore, since none of the servers we've tested against in earlier
> Bakeathons and Connectathons have complained, I suggest that we rather
> change the spec with an errata.

Argh.

I just noticed that the server was crashing intermittently and traced it
to incorrect handling of the case where the client sends a one-op
SEQUENCE compound with seqid 0.  I'm not sure why it started popping up
just in 3.3--perhaps some change in the way the client uses slots made
that more likely.

The server code actually looks like it did assume initial seqid 1, but
accepted initial seqid 0 (except in this one case) basically by mistake.

In any case, I think it should be easy enough to teach it just to accept
any seqid on a previously unused slot, so I'll do that....

--b.
