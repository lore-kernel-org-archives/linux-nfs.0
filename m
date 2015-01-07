Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46074 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859AbbAGSz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2015 13:55:27 -0500
Date: Wed, 7 Jan 2015 13:55:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Remove function macros from nfs4_fs.h
Message-ID: <20150107185525.GC7066@fieldses.org>
References: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1C602278-4A23-4975-8339-7AFF0606B154@primarydata.com>
 <20150106190800.GB28003@fieldses.org>
 <2705333F-CCAE-44E2-BD42-76FEB452B764@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <2705333F-CCAE-44E2-BD42-76FEB452B764@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 07, 2015 at 01:47:53PM -0500, Weston Andros Adamson wrote:
> Ah, right, but only for state operations that don’t touch the filesystem:
> 
> OP_BIND_CONN_TO_SESSION
> OP_EXCHANGE_ID
> OP_CREATE_SESSION
> OP_DESTROY_SESSION
> OP_DESTROY_CLIENTID
> 
> Which is not that interesting, since the client should already be using the machine cred
> with these operations.
> 
> What is interesting is supporting write and commit (and associated ops, i.e. sequence).
> That way when a client is doing buffered writes and the user cred expires, it can flush the
> locally cached data. This is what the linux client SP4_MACH_CRED feature focused on.
> 
> I think implementing SP4_MACH_CRED for these operations has the issue I mentioned
> earlier: the fh_verify path will have to check credentials against some cached credential
> (tied to the stateid), because request will contain the machine credential and not the user
> credential that previous writes (before cred expiration) used.

Oh, I see.  Yeah, that sounds like a bigger project.

--b.
