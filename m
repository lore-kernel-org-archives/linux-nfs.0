From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1 v2] nfs41: pass state recovery error back to caller
Date: Wed, 02 Sep 2009 13:52:40 -0400
Message-ID: <1251913960.26601.41.camel@heimdal.trondhjem.org>
References: <1251877725-12113-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40316 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153AbZIBRxd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Sep 2009 13:53:33 -0400
In-Reply-To: <1251877725-12113-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-09-02 at 10:48 +0300, Benny Halevy wrote:
> Currently the error returned from create_session
> is ignored by nfs4_check_client_ready and mis-translated to
> -EPROTONOSUPPORT if the client has a session.
> Record the error returned from create_session to the state manager
> in cl_cons_state via nfs_mark_client_ready and pass it upstream
> in nfs4_recover_expired_lease.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---

Firstly, if you're out to save 4 bytes by sharing storage with an object
of an entirely different type, then please use an explicit union. Then
use a special state NFS4CLNT_LEASE_RECLAIM_FAILED in order to clearly
label what is being stored in that union.

Secondly, I'd say that it is more natural to share storage with the
client id, cl_ex_clid, rather than using the lease time. The latter is
read via an entirely separate RPC call _after_ you are done establishing
the lease and the first session.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
