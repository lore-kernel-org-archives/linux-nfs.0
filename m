From: Randy Dunlap <rdunlap@xenotime.net>
Subject: sunrpc new kernel-doc warnings
Date: Sun, 13 Sep 2009 18:53:19 -0700
Message-ID: <20090913185319.e462e73c.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.64.118]:35119 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754742AbZINBxR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Sep 2009 21:53:17 -0400
Received: from chimera.site ([96.253.169.185]) by xenotime.net for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2009 18:53:19 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent commit e57aed77ad48d28ac617ba157ad2f665f5301b30 ignored the kernel-doc
notation for function rpc_create_client_dir().  Now creating kernel-doc
produces warnings:

Warning(net/sunrpc/rpc_pipe.c:874): No description found for parameter 'dentry'
Warning(net/sunrpc/rpc_pipe.c:874): No description found for parameter 'name'
Warning(net/sunrpc/rpc_pipe.c:874): Excess function parameter 'path' description in 'rpc_create_client_dir'


Please correct them.

thanks,
---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
