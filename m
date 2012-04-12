Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59593 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398Ab2DLGEb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2012 02:04:31 -0400
Received: by pbcun15 with SMTP id un15so1980712pbc.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Apr 2012 23:04:31 -0700 (PDT)
Date: Thu, 12 Apr 2012 14:04:22 +0800 (China Standard Time)
From: anctop@gmail.com
To: linux-nfs@vger.kernel.org
Subject: how to specify a port number for rpc.statd ?
In-Reply-To: <S1756522Ab2DLFb0/20120412053126Z+1423@vger.kernel.org>
Message-ID: <alpine.WNT.2.00.1204121340311.4084@x035>
References: <S1756522Ab2DLFb0/20120412053126Z+1423@vger.kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


My system has been running nfs-utils-1.2.0 for a few years.
Recently I proceed to upgrade to the latest nfs-utils-1.2.5.
There is no problem in building it, but rpc.statd refuses to start.
The (server) startup steps are :

1. mount -t nfsd /proc/fs/nfsd
2. exportfs -av
3. rpc.mountd -p 1011
4. rpc.statd -o 1013 -p 1014 --no-notify

At this point, rpc.statd fails. The syslog says

> rpc.statd[875]: Version 1.2.5 starting
> rpc.statd[875]: Flags:
> rpc.statd[875]: Could not bind name to socket: Permission denied

The same steps work well for the old version, and I'm sure that all the ports 
(tcp & udp) 1011, 1013 & 1014 are available on my system.

Then I've tried different combinations of values for -o and -p, found that 
the port number for -p must be at least 1024.

Since the daemons will run with a firewall, is there any way to make 
rpc.statd listening on the specified ports ?
