Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:26925 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317Ab2FGPmw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 11:42:52 -0400
Subject: Re: [PATCH] NFS: Fix a commit bug
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <ABEA57CF-6358-4FFE-9CB6-35F9CD2616B8@oracle.com>
Date: Thu, 7 Jun 2012 11:42:48 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Message-Id: <16A50E40-0250-4975-8001-8B1B2AF4696A@oracle.com>
References: <1338936204-20168-1-git-send-email-Trond.Myklebust@netapp.com> <73EB71C8-FD1B-4508-8474-D87C9B7312EC@netapp.com> <ABEA57CF-6358-4FFE-9CB6-35F9CD2616B8@oracle.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 7, 2012, at 11:05 AM, Chuck Lever wrote:

> This does not appear to fix the problem I'm seeing.
> 
> With this patch applied, the client is silly renaming the file, deleting it, then writing it again and failing with NFS4ERR_STALE.
> 
> I had to apply the change by hand, so I could have missed something.  I'll go back and check.

The patch was missing a hunk, now fixed.  I still see misbehavior.  But, the re-writes are occurring because the client gets an error while writing to the DS, and fails over to the MDS and retries the writes.  So I'm seeing a different bug.

---
Chuck Lever
chuck [dot] lever [at] oracle [dot] com




