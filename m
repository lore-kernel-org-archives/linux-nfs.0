Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21613 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752973AbdAZT6A (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 14:58:00 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2] nfs: Don't increment lock sequence ID after NFS4ERR_MOVED
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1485454442.9473.1.camel@primarydata.com>
Date: Thu, 26 Jan 2017 14:57:18 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <114AE9BE-01D7-478A-AC57-5A0C878FF701@oracle.com>
References: <20170126175938.6021.69650.stgit@manet.1015granger.net> <1485454442.9473.1.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 26, 2017, at 1:14 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Thu, 2017-01-26 at 13:00 -0500, Chuck Lever wrote:
>> Xuan Qi reports that the Linux NFSv4 client failed to lock a file
>> that was migrated. The steps he observed on the wire:
>> 
>> 1. The client sent a LOCK request to the source server
>> 2. The source server replied NFS4ERR_MOVED
>> 3. The client switched to the destination server
>> 4. The client sent the LOCK request to the destination
>> ย ย ย server with a bumped lock sequence ID
>> 5. The destination server rejected the LOCK request with
>> ย ย ย NFS4ERR_BAD_SEQID
>> 
>> RFC 3530 section 8.1.5 provides a list of NFS errors which do not
>> bump a lock sequence ID.
>> 
>> However, RFC 3530 is now obsoleted by RFC 7530. In RFC 7530 section
>> 9.1.7, this list has been updated by the addition of NFS4ERR_MOVED.
>> 
>> Reported-by: Xuan Qi <xuan.qi@oracle.com>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Tested-by: Xuan Qi <xuan.qi@oracle.com>
>> Cc: stable@vger.kernel.org # v3.7+
>> ---
>> Testing confirms this patch addresses the problem that Xuan first
>> observed.
>> 
> 
> Since the first patch was already applied to linux-next, could you
> please make this one incremental?

Is there a stable commit ID for v1 of this patch?

Just wondering if I should include a Fixes: tag in the incremental
patch.


--
Chuck Lever



