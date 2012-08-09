Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:49749 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752102Ab2HIImj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 04:42:39 -0400
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="utf-8"
Date: Thu, 09 Aug 2012 10:42:36 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <20120808182622.177380@gmx.net>
Message-ID: <20120809084236.177380@gmx.net>
MIME-Version: 1.0
References: <20120808155829.177400@gmx.net> <20120808163916.GA24539@umich.edu>
 <20120808182622.177380@gmx.net>
Subject: Re: Blocklayout
To: "Johannes Schild" <JSchild@gmx.de>, rees@umich.edu
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Guys,

some additional Information, 

[ 1644.874549] FS-Cache: Loaded
[ 1644.895122] NFS: Registering the id_resolver key type
[ 1644.895158] FS-Cache: Netfs 'nfs' registered for caching
[ 1644.920204] blkmapd: sending ioctl 2285 to a partition!
[ 1644.920207] blkmapd: sending ioctl 2285 to a partition!
[ 1644.920208] blkmapd: sending ioctl 2285 to a partition!
[ 1644.920263] blkmapd: sending ioctl 2285 to a partition!
[ 1644.920264] blkmapd: sending ioctl 2285 to a partition!
[ 1644.920265] blkmapd: sending ioctl 2285 to a partition!
[ 1653.129460] blkmapd: sending ioctl 2285 to a partition!
[ 1653.129463] blkmapd: sending ioctl 2285 to a partition!
[ 1653.129464] blkmapd: sending ioctl 2285 to a partition!
[ 1653.129528] blkmapd: sending ioctl 2285 to a partition!
[ 1653.129530] blkmapd: sending ioctl 2285 to a partition!
[ 1653.129531] blkmapd: sending ioctl 2285 to a partition!
[ 1653.136682] NFS: set_pnfs_layoutdriver: Error initializing pNFS layout driver 3.

someone any ideas whats going wrong? The above output is from dmesg.
Iam using 3.4.7-1.fc16.x86_64 Kernel from Fedora. The utils are from  http://steved.fedorapeople.org/repos/pnfs.

Thanks.

Johannes

