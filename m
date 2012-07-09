Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:18565 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864Ab2GIUPb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 16:15:31 -0400
Subject: Re: [PATCH 03/14] NFS: State reclaim clears OPEN and LOCK state
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1341864200.15267.15.camel@lade.trondhjem.org>
Date: Mon, 9 Jul 2012 16:15:27 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <773D0923-FC7B-4CE9-8EDE-46BC18E9A49C@oracle.com>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net> <20120709154409.1604.59004.stgit@degas.1015granger.net> <1341864200.15267.15.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 9, 2012, at 4:03 PM, Myklebust, Trond wrote:

> On Mon, 2012-07-09 at 11:44 -0400, Chuck Lever wrote:
>> Before beginning state recovery, the state manager zaps open and lock
>> state for each open file, thus the "state->flags & flags" test in
>> nfs41_{open,lock}_expired() always fails during reclaim.  But open
>> recovery is still needed for these files.
>> 
>> To force a call to nfs4_open_expired(), change the default return
>> value for nfs41_check_expired_stateid() to force open recovery, and
>> the default return value for nfs41_check_locks() to force lock
>> recovery, if the requested flags are clear.  Fix suggested by Bryan
>> Schumaker.
> 
> This makes absolutely no sense...
> 
> The point of these function should be to test if the stateid is still
> valid. If it is, then we need no recovery.
> If the stateid is _not_ valid, then we free it, and then decide if
> recovery is needed. The only exception to that rule is if TEST_STATEID
> returns NFS4ERR_BAD_STATEID, (in which case we don't need to free the
> stateid but just recover immediately).

So you'd like to change the sense of the switch statement in my earlier patch:

   NFS4_OK:
     do nothing
   NFS4ERR_BAD_STATEID:
     just open
   default:
     free the state ID, then open

I still don't think we need a FREE_STATEID call for NFS4ERR_EXPIRED, for example.  It seems to me the only cases where FREE_STATEID is needed is the _REVOKED cases.

> IOW: The state->flags and lsp->ls_flags tests should just be removed.

Bryan had a reason to leave those tests in, but I don't remember what it was.

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




