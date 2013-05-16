Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:24985 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab3EPMcO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 May 2013 08:32:14 -0400
Date: Thu, 16 May 2013 15:31:57 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: re: SUNRPC: Convert auth_gss pipe detection to work in namespaces
Message-ID: <20130516123156.GA19760@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond Myklebust,

The patch 11575f2498f5: "SUNRPC: Convert auth_gss pipe detection to
work in namespaces" from May 15, 2013, leads to the following Smatch
warnings:

net/sunrpc/auth_gss/auth_gss.c:275 get_pipe_version() warn: always true condition '(sn->pipe_version >= 0) => (0-u32max >= 0)'"
net/sunrpc/auth_gss/auth_gss.c:732 gss_pipe_open() warn: unsigned 'sn->pipe_version' is never less than zero.
net/sunrpc/auth_gss/auth_gss.c:590 gss_create_upcall() warn: unsigned 'sn->pipe_version' is never less than zero.

net/sunrpc/auth_gss/auth_gss.c
   274          spin_lock(&pipe_version_lock);
>  275          if (sn->pipe_version >= 0) {
   276                  atomic_inc(&sn->pipe_users);
   277                  ret = sn->pipe_version;
   278          } else
   279                  ret = -EAGAIN;

[snip]

>  590                  if (sn->pipe_version < 0) {
   591                          if (err == 0)
   592                                  sn->gssd_running = 0;
   593                          warn_gssd();
   594                          err = -EACCES;
   595                  }
   596                  if (err < 0)
   597                          goto out;

[snip]

   731          spin_lock(&pipe_version_lock);
>  732          if (sn->pipe_version < 0) {
   733                  /* First open of any gss pipe determines the version: */
   734                  sn->pipe_version = new_version;
   735                  rpc_wake_up(&pipe_version_rpc_waitqueue);
   736                  wake_up(&pipe_version_waitqueue);
   737          } else if (sn->pipe_version != new_version) {
   738                  /* Trying to open a pipe of a different version */
   739                  ret = -EBUSY;
   740                  goto out;
   741          }

regards,
dan carpenter

