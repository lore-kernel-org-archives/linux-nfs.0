Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9503 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755192Ab1EPTuk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 15:50:40 -0400
Subject: Re: SEQ4_STATUS_ question
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <FB972601-FDA2-4C1D-B695-5D268CD568C1@oracle.com>
References: <FB972601-FDA2-4C1D-B695-5D268CD568C1@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 16 May 2011 15:50:38 -0400
Message-ID: <1305575438.19725.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-05-16 at 15:40 -0400, Chuck Lever wrote:
> Hi-
> 
> In minor version 1, the "lease moved" condition is indicated via a flag set in the result of a SEQUENCE operation; in mv0, it was a real NFS4ERR status code.
> 
> I don't see anything in RFC 5661 that says SEQUENCE returns anything but NFS4_OK if one or more of these flags are set.  But nfs41_sequence_call_done checks these status flags only when task->tk_status < 0.
> 
> If SEQUENCE returns a non-NFS4_OK status code when these flags are set, and MUST be the first operation in a compound, how can anything else in any compound with a SEQUENCE operation get done?
> 
> To clear a "lease moved" condition requires that the client send an operation that will get an NFS4ERR_MOVED result.  I assume such a compound would require an initial SEQUENCE operation... but that should fail, since there is a "lease moved" condition.
> 
> What am I missing?
> 

What am _I_ missing? As far as I can see, the status flags are checked
in 2 places:

      * nfs41_sequence_done() if and only if the sequence operation
        status is zero (in which case we schedule a lease verification)
      * In nfs4_proc_sequence(), if and only if the task->tk_status ==
        0.

I can't see any checks in nfs41_sequence_call_done...

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

