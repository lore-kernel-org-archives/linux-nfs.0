Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:24225 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757296Ab3EOQSF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 12:18:05 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] [RFC] Maybe avoid gssd upcall timeout
Date: Wed, 15 May 2013 16:18:03 +0000
Message-ID: <1368634683.3568.5.camel@leira.trondhjem.org>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
In-Reply-To: <20130513161515.1942.845.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-05-13 at 12:25 -0400, Chuck Lever wrote:
> Hi-
> 
> Here's a stab at addressing the 15 second wait for some 3.10 sec=sys
> mounts where the client is not running rpc.gssd.
> 
> After reverting the "use krb5i for SETCLIENTID" patch, I've added
> the AUTH_SYS fallback in the EACCES case in
> nfs4_discover_server_trunking().  I'm not sure whether we need to
> supplement what's there now, or replace it.
> 
> "case -ENOKEY:" is added so the kernel will recognize that when gssd
> is changed to return that instead of EACCES in this case.  If the
> second patch is appled to 3.7 stable and following, it might be a way
> to address the same regression in older kernels.
> 
> I've been focused on another bug this week, so this has seen very
> light testing only.  Looking for comments.

I'd like to propose a different approach: we can set up rpc_pipefs files
clnt/gssd and clnt/krb5 as "honeypots" that rpc.gssd will connect to,
but that won't do any upcalls. When gssd connects, we set a
per-rpc_net_ns variable that tells us 'gssd' is up and running. That
variable only gets cleared if we see a timeout.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
