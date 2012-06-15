Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ferdi.naasa.net ([87.106.227.76]:51389 "EHLO ferdi.naasa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932111Ab2FOPYQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jun 2012 11:24:16 -0400
Message-ID: <4FDB539A.8060409@naasa.net>
Date: Fri, 15 Jun 2012 17:24:10 +0200
From: Joerg Platte <jplatte@naasa.net>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Joerg Platte <jplatte@naasa.net>, bfields <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Kernel 3.4.X NFS server regression
References: <4FD47D4E.9070307@naasa.net> <1339340441.4751.1.camel@lade.trondhjem.org>
In-Reply-To: <1339340441.4751.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm replying to this bug report since I found another nfs server 
regression with the same kernel version (3.4.2), so the subject matches. 
This time it is a "kernel BUG at fs/nfsd/nfs4state.c:1044"

Since the machine was not responsive after the BUG and rebooted I was 
only able to take a picture of the full stacktrace. You can download it 
from here:

https://ferdi.naasa.net/url/jplatte/IMG_3139.JPG

The patch "[PATCH] rpc_pipefs: allow rpc_purge_list to take a NULL waitq 
pointer" was not applied for this trace, but the bug is the same with 
this patch applied. So there must be another problem.

The crash is reproducable just by creating some nfs traffic and I can 
hit it within minutes.

regards,
Joerg
