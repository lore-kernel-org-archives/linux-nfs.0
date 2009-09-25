From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Ping: [pnfs] [RFC 1/1] nfs4: optionally return status from
 state_manager
Date: Fri, 25 Sep 2009 10:13:38 -0400
Message-ID: <1253888019.31072.31.camel@heimdal.trondhjem.org>
References: <4A9EDDE6.1090308@panasas.com>
	 <1251990924-3904-1-git-send-email-bhalevy@panasas.com>
	 <4ABC477E.4060709@panasas.com>
	 <1253885382.31072.14.camel@heimdal.trondhjem.org>
	 <4ABCCB4D.4020603@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65428 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649AbZIYONw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2009 10:13:52 -0400
In-Reply-To: <4ABCCB4D.4020603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-09-25 at 16:53 +0300, Benny Halevy wrote:
> That scenario is caused when the server's /etc/exports
> is badly configured, where the export entry for nfsv4
> (fsid=0) exports a non-existing path.
> 
> I agree that the server should not return ENOENT
> for PUTROOTFH as it contradicts the spec.
> NFS4ERR_SERVERFAULT seems more appropriate.

Indeed.

> The main reason for getting the failure from
> the state engine in nfsv4.1 is that we need to
> create a session before nfs4_path_walk in nfs4_create_server
> and we do that using the state manager.
> In the nfsv4.0 case we create no state at this point.

OK, so this particular case, there is no state recovery possible at all.
If so, why not just label the cl_cons_state as NFS_CS_IRRECOVERABLE (or
possibly NFS_CS_SERVERFAULT) instead of trying to overload it with an
error value that nobody can do anything about?

I'd say that if you want to pass the error value to the administrator,
then the right way to do that would be via a printk. Something along the
lines of

printk("NFSv4: Server %s returned an illegal error %d when getting the
root filehandle\n");

However, I'm not really convinced that is necessary...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
