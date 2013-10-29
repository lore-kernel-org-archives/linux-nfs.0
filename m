Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51115 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508Ab3J2Mow convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 08:44:52 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Hellwig Christoph <hch@infradead.org>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Date: Tue, 29 Oct 2013 12:44:50 +0000
Message-ID: <BF996CAD-1032-4434-A538-B678D047884B@netapp.com>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
 <20131029073943.GD10889@infradead.org>
In-Reply-To: <20131029073943.GD10889@infradead.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 3:39 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Oct 28, 2013 at 11:00:17AM -0400, Anna Schumaker wrote:
>> Clients are required to support CB_OFFLOAD for the NFS4_CONTENT_HOLE arm
>> of the WRITE_PLUS union.
> 
> This sounds pretty stupid.  Just curious, who got this braindamage into
> the standard?
> 

It exists because the server vendors were worried that operations such as preallocation and/or hole punching can take a more or less unbounded amount of time due to the 64-bit size. By using an (optional) callback method, the server can free up the RPC slot that would otherwise be kept waiting in the synchronous case.

Cheers
  Trond