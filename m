Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934805Ab3FSOHN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jun 2013 10:07:13 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1371649292.5522.1.camel@leira.trondhjem.org>
References: <1371649292.5522.1.camel@leira.trondhjem.org> <20130618201248.6cc88501@csupomona.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: dhowells@redhat.com, Brian De Wolf <bldewolf@csupomona.edu>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Issues using new idmapper in large sites
Date: Wed, 19 Jun 2013 15:07:10 +0100
Message-ID: <7562.1371650830@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> > It's fast but...it also missed most of my users (it only has 503
> > cached, there are 36287 total).  The refcount and number of keys
> > skyrocket even further on repeated runs but the number of missing
> > users remains the same.

Okay...  I need to improve keyring capacity.

Current max keyring capacity is

	(PAGE_SIZE - header) / sizeof(key *)

in other words, 500-ish on a 64-bit machine.

Let me have a play - in theory, it shouldn't be too hard; the main trick is
retaining RCU-based reading and, ideally, tree size.  Plus if I can sort it
too...

David
