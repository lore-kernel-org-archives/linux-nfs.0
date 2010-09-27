Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14054 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750841Ab0I0KF5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:05:57 -0400
Message-ID: <4CA06C7A.5060307@parallels.com>
Date: Mon, 27 Sep 2010 14:05:46 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 0/8] sunrpc: Create sockets in namespaces
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi!

This set implements pulling the net * argument down to the existing
sock_create_kern calls in the sunrpc layer and creating the sockets
in the given net.

Patch #7 opens the __sock_create for public and I hope we can do it
not in the Dave's tree :)

Applies to git://linux-nfs.org/~bfields/linux.git nfsd-next after the
ip_map_cache virtualization patch set I sent before.

Thanks,
Pavel
