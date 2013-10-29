Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:47584 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752757Ab3J2NFp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 09:05:45 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Hellwig Christoph <hch@infradead.org>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Date: Tue, 29 Oct 2013 13:05:44 +0000
Message-ID: <58212CB2-A01A-43F1-8760-5ED8ED75E081@netapp.com>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
 <20131029073943.GD10889@infradead.org>
 <BF996CAD-1032-4434-A538-B678D047884B@netapp.com>
 <20131029124836.GA13482@infradead.org>
In-Reply-To: <20131029124836.GA13482@infradead.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 8:48 AM, Hellwig Christoph <hch@infradead.org> wrote:

> On Tue, Oct 29, 2013 at 12:44:50PM +0000, Myklebust, Trond wrote:
>> It exists because the server vendors were worried that operations such as preallocation and/or hole punching can take a more or less unbounded amount of time due to the 64-bit size. By using an (optional) callback method, the server can free up the RPC slot that would otherwise be kept waiting in the synchronous case.
> 
> Must be some horried filesystems on those vendors servers.  Both
> operations should be O(nr_extents), where nr_extents should be extremely
> low for the preallocation and still reasonably low for hole punches,
> although users control the allocastion pattern.
> 
> There's a reason why these aren't aio operations locally either.
> 

Imagine someone wanting to punch a 50TB hole in NTFS, for instance. It doesn't have real holes, so you'd end up needing to zero out the existing extents in that region of the file. That will take time, even with an O(nr_extents) algorithm.


