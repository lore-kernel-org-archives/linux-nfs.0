Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51690 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988Ab3EPNWj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 May 2013 09:22:39 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: SUNRPC: Convert auth_gss pipe detection to work in namespaces
Date: Thu, 16 May 2013 13:22:37 +0000
Message-ID: <1368710557.6041.0.camel@leira.trondhjem.org>
References: <20130516123156.GA19760@elgon.mountain>
In-Reply-To: <20130516123156.GA19760@elgon.mountain>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-16 at 15:31 +0300, Dan Carpenter wrote:
> Hello Trond Myklebust,
> 
> The patch 11575f2498f5: "SUNRPC: Convert auth_gss pipe detection to
> work in namespaces" from May 15, 2013, leads to the following Smatch
> warnings:
> 
> net/sunrpc/auth_gss/auth_gss.c:275 get_pipe_version() warn: always true condition '(sn->pipe_version >= 0) => (0-u32max >= 0)'"
> net/sunrpc/auth_gss/auth_gss.c:732 gss_pipe_open() warn: unsigned 'sn->pipe_version' is never less than zero.
> net/sunrpc/auth_gss/auth_gss.c:590 gss_create_upcall() warn: unsigned 'sn->pipe_version' is never less than zero.

Thanks Dan! It's fixed now...
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
