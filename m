From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/8] SUNRPC: Use RPC procedure name in call_verify
Date: Tue, 20 May 2008 17:56:21 -0400
Message-ID: <1211320581.574.17.camel@localhost>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
	 <20080520202941.3851.61861.stgit@ellison.1015granger.net>
	 <1211318498.26809.13.camel@localhost>
	 <DF95EE8C-4F20-4B4A-9967-9AD354196D4D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7121 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934225AbYETV6W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 17:58:22 -0400
In-Reply-To: <DF95EE8C-4F20-4B4A-9967-9AD354196D4D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-20 at 17:39 -0400, Chuck Lever wrote:

> How could you ever get an RPC_PROC_UNAVAIL with a NULL RPC?

You shouldn't, given a well adjusted server, but that's not equivalent
to saying that it can't ever happen. 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
