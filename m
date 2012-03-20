Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:19861 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab2CTUaL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 16:30:11 -0400
Subject: Re: dprintk() considered harnful!
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120320131743.8460097d.akpm@linux-foundation.org>
Date: Tue, 20 Mar 2012 16:30:06 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CEA41BF7-A57C-4296-8142-B02466E4A2BC@oracle.com>
References: <20120320131743.8460097d.akpm@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 20, 2012, at 4:17 PM, Andrew Morton wrote:

> net/sunrpc/rpcb_clnt.c: In function 'rpcb_enc_mapping':
> net/sunrpc/rpcb_clnt.c:820: warning: unused variable 'task'
> net/sunrpc/rpcb_clnt.c: In function 'rpcb_dec_getport':
> net/sunrpc/rpcb_clnt.c:837: warning: unused variable 'task'
> net/sunrpc/rpcb_clnt.c: In function 'rpcb_dec_set':
> net/sunrpc/rpcb_clnt.c:860: warning: unused variable 'task'
> net/sunrpc/rpcb_clnt.c: In function 'rpcb_enc_getaddr':
> net/sunrpc/rpcb_clnt.c:892: warning: unused variable 'task'
> net/sunrpc/rpcb_clnt.c: In function 'rpcb_dec_getaddr':
> net/sunrpc/rpcb_clnt.c:914: warning: unused variable 'task'


Which kernel version?  I assume that RPC_DEBUG (or CONFIG_SUNRPC_DEBUG) is disabled?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




