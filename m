Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753793Ab3JXPQQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 11:16:16 -0400
Subject: Re: XATTRs in NFS?
From: Simo Sorce <simo@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Christoph Anton Mitterer <calestyo@scientia.net>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
In-Reply-To: <1382627496.6430.2.camel@leira.trondhjem.org>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
	 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
	 <1382624000.6907.8.camel@heisenberg.scientia.net>
	 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
	 <1382627225.899.76.camel@willson.li.ssimo.org>
	 <1382627496.6430.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Oct 2013 11:16:10 -0400
Message-ID: <1382627770.899.79.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-24 at 15:11 +0000, Myklebust, Trond wrote:
> On Thu, 2013-10-24 at 11:07 -0400, Simo Sorce wrote:
> 
> > Because the filesystem can do that when multiple applications are
> > involved without having to change them all to talk to each other and
> > invent custom protocol all the time just to keep some additional
> > metadata associated to a file..
> > 
> It's still a custom protocol. The applications need to agree on a data
> format and store it somewhere. The portable way to do this is to write
> an application library that they can link to.

Perhaps I was unclear, you are never going to see that custom library
linked into the 'mv' command.

So your approach makes little sense if the object is to maintain data
coherent when people need to handle files from random applications and
scripts and general system maintenance.

The data may be relevant only to a specific application.

I am not saying you *have* to implement xattrs support, just saying that
it is not a mere 'applications should synchronize data themselves'
problem.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

