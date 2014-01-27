Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:63003 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbaA0Rko convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 12:40:44 -0500
Received: by mail-ie0-f182.google.com with SMTP id lx4so6264225iec.27
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 09:40:43 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 1/1] NFSv4.1 Do not preallocate session slots in nfs4_end_drain_slot_tbl
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1390843555-3498-1-git-send-email-andros@netapp.com>
Date: Mon, 27 Jan 2014 12:40:42 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <6EB54911-838A-4E42-AA4B-B276DD52F439@primarydata.com>
References: <1390843555-3498-1-git-send-email-andros@netapp.com>
To: Adamson William Andros <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 27, 2014, at 12:25, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> Pre-allocating session slots for RPC tasks waking up from a wait queue provides
> a shorter slot allocation code path and can help performance.
> 
> Durring multiple server reboots (interface moves), the pre-allocated
> slot can be held and not freed as a task is transferred to various slot table
> wait queues and the state manager is draining these queues.  Not freeing the
> slots results in a  state manager hang waiting for completion on the slot
> table draining.  In this case, performance is not a consideration as the
> client is in recovery of a session or a clientid.
> 

I’m not understanding this reasoning. If the slot table is drained, then the slots must be returned to the session manager by all outstanding RPC calls so that the state manager thread can go about its business. By what mechanism are these slots being held and not freed here?

> Prevent this state manager hang by not pre-allocating session slots, but
> just wake up the tasks and let them grab a sessions slot in the
> nfs4_alloc_slot call in nfs41-setup_sequence.

If the slots are already held, then how does this help?

--
Trond Myklebust
Linux NFS client maintainer

