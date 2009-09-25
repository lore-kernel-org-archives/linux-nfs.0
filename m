From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Ping: [pnfs] [RFC 1/1] nfs4: optionally return status from
 state_manager
Date: Fri, 25 Sep 2009 09:29:42 -0400
Message-ID: <1253885382.31072.14.camel@heimdal.trondhjem.org>
References: <4A9EDDE6.1090308@panasas.com>
	 <1251990924-3904-1-git-send-email-bhalevy@panasas.com>
	 <4ABC477E.4060709@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39229 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbZIYNaJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2009 09:30:09 -0400
In-Reply-To: <4ABC477E.4060709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-09-25 at 07:30 +0300, Benny Halevy wrote:
> Trond,
> 
> Is the patch below acceptable?
> 
> Benny

I'm still not entirely happy with the idea that the state manager can
get into situations where it needs outside help, and you haven't really
explained to me the root cause of the scenario.
You said something about

nfs4_create_server()
nfs4_init_session()
nfs4_recover_expired_lease()
        nfs4_schedule_state_recovery()
                # and the failure happens within the state engine
                nfs4_proc_create_session()
                nfs4_proc_get_lease_time() return -2

Where does that ENOENT come from?

You said something about it being an error in OP_PUTROOTFH, but as far
as I can see, the only permitted errors for putrootfh are either session
related errors (which should be handled by the state machine),
NFS4ERR_DELAY (which should be handled by the state machine) and
NFS4ERR_WRONGSEC. So which error is generating your ENOENT?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
