Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39062 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933011Ab3EOSPx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 14:15:53 -0400
Date: Wed, 15 May 2013 14:15:51 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] [RFC] Maybe avoid gssd upcall timeout
Message-ID: <20130515181551.GP16811@fieldses.org>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
 <1368634683.3568.5.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368634683.3568.5.camel@leira.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 04:18:03PM +0000, Myklebust, Trond wrote:
> On Mon, 2013-05-13 at 12:25 -0400, Chuck Lever wrote:
> > Hi-
> > 
> > Here's a stab at addressing the 15 second wait for some 3.10 sec=sys
> > mounts where the client is not running rpc.gssd.
> > 
> > After reverting the "use krb5i for SETCLIENTID" patch, I've added
> > the AUTH_SYS fallback in the EACCES case in
> > nfs4_discover_server_trunking().  I'm not sure whether we need to
> > supplement what's there now, or replace it.
> > 
> > "case -ENOKEY:" is added so the kernel will recognize that when gssd
> > is changed to return that instead of EACCES in this case.  If the
> > second patch is appled to 3.7 stable and following, it might be a way
> > to address the same regression in older kernels.
> > 
> > I've been focused on another bug this week, so this has seen very
> > light testing only.  Looking for comments.
> 
> I'd like to propose a different approach: we can set up rpc_pipefs files
> clnt/gssd and clnt/krb5

I'm not sure what paths you mean exactly?  Is "clnt" a top-level
rpc-pipefs directory, or a dummy client at the level of other rpc
clients (like rpc_pipefs/nfs/clnt/gssd).

I'm assuming the latter--seems like it might work.

Long-term, it might also be nice to add an interface to allow the kernel
to determine whether gssd is running, without depending on timeouts.  It
could be something very trivial.

--b.

> as "honeypots" that rpc.gssd will connect to,
> but that won't do any upcalls. When gssd connects, we set a
> per-rpc_net_ns variable that tells us 'gssd' is up and running. That
> variable only gets cleared if we see a timeout.
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
