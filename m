Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vms173015pub.verizon.net ([206.46.173.15]:47495 "EHLO
	vms173015pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab0ETUB1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 May 2010 16:01:27 -0400
Received: from backoffice.bplinux.com ([unknown] [98.118.141.73])
 by vms173015.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0L2Q00LESI9NSKPA@vms173015.mailsrvcs.net> for
 linux-nfs@vger.kernel.org; Thu, 20 May 2010 15:01:03 -0500 (CDT)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by backoffice.bplinux.com (Postfix) with ESMTP id AD2693E8002	for
 <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 15:54:29 -0400 (EDT)
Received: from backoffice.bplinux.com ([127.0.0.1])
	by localhost (backoffice.bplinux.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gBro3btDFtYd for <linux-nfs@vger.kernel.org>; Thu,
 20 May 2010 15:54:28 -0400 (EDT)
Received: from backoffice.bplinux.com (backoffice.bplinux.com [192.168.1.4])
	by backoffice.bplinux.com (Postfix) with ESMTP id DC13F3E8001	for
 <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 15:54:28 -0400 (EDT)
Date: Thu, 20 May 2010 15:54:28 -0400 (EDT)
From: Christopher Hawkins <chawkins@bplinux.com>
To: linux-nfs@vger.kernel.org
Message-id: <25273515.321274385268620.JavaMail.javamailuser@localhost>
In-reply-to: <3726796.301274385081605.JavaMail.javamailuser@localhost>
Subject: nfs4 hang
Content-type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello, 

I have a bash script that sets up a root filesystem over NFS. The method works fine over NFS3 but hangs when using NFS4 as a transport. Hoping someone can help me figure out why?

In a nutshell:

1. The node boots into a ramdisk that has a few thousand files in it already
2. connects to an NFS server exporting / and mounts that in a tmp dir
3. bash (on the booting node) loops through the local and remote filesystem and creates a local symlink to anything in the nfs root that it doesn't already have.

Export options are: / 192.168.1.0/24(rw,no_root_squash,no_subtree_check,fsid=0)
Mount options are: rw,sync,noatime,rsize=1024,wsize=1024

rpcidmapd, portmap, statd are running on server and client, and rpc_pipefs is mounted on both as well. The script currently makes about 6200 links, total. Nfs4 hangs about 90% of the way through. I removed the directory it was hanging on (a simple, empty dir) and then it just hung on the next one.

Really appreciate any help or pointers on where to look for more info. Thanks!

Chris


   
