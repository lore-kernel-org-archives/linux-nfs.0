Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:35613 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab1KNRPL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 12:15:11 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RQ07e-00021f-4A
	for linux-nfs@vger.kernel.org; Mon, 14 Nov 2011 18:15:08 +0100
Received: from a2-49.ltk.com.ua ([195.69.202.49])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 18:15:06 +0100
Received: from free.lan.c2.718r by a2-49.ltk.com.ua with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 18:15:06 +0100
To: linux-nfs@vger.kernel.org
From: Pavel <free.lan.c2.718r@gmail.com>
Subject: clients fail to reclaim locks after server reboot or manual sm-notify
Date: Mon, 14 Nov 2011 17:11:56 +0000 (UTC)
Message-ID: <loom.20111114T180637-632@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi! I'm trying to set up an NFS server (particularly an A/A NFS cluster) and 
having issues with locking and reboot notifications. These are the tests I have 
done:

1. The simplest test includes single NFS server machine (Debian Squeeze), 
running nfs-kernel-server (nfs-utils 1.2.2-4) and a single client machine (same 
OS), that mounts a share with “-o 'vers=3'” option. From the client I lock some 
file on share using 'testlk -w <filename>' (testlk from nfsutils/tools/locktest) 
so that a corresponding file appears in /var/lib/nfs/sm/ on server. Then I 
reboot the server and this is what I get in client logs:

lockd: request from 127.0.0.1, port=1007
lockd: SM_NOTIFY     called
lockd: host nfs-server1 (192.168.0.101) rebooted, cnt 2
lockd: get host nfs-server1
lockd: get host nfs-server1
lockd: release host nfs-server1
lockd: reclaiming locks for host nfs-server1
lockd: rebind host nfs-server1
lockd: call procedure 2 on nfs-server1
lockd: nlm_bind_host nfs-server1 (192.168.0.101)
lockd: rpc_call returned error 13
lockd: failed to reclaim lock for pid 1555 (errno -13, status 0)
NLM: done reclaiming locks for host nfs-server1
lockd: release host nfs-server1

2. As I'm building a cluster I'll need to notify clients when NFS resource 
migrates (since it is an A/A cluster nfs-kernel-server is always running on all 
nodes and shares migrate using exportfs resource agent), but manually calling 
sm-notify ('sm-notify -f -v <virtual IP of share>') from either the initial for 
that share or backup node results in the following (client logs):

lockd: request from 127.0.0.1, port=637
lockd: SM_NOTIFY     called
lockd: host B (192.168.0.110) rebooted, cnt 2
lockd: get host B
lockd: get host B
lockd: release host B
lockd: reclaiming locks for host B
lockd: rebind host B
lockd: call procedure 2 on B
lockd: nlm_bind_host B (192.168.0.110)
lockd: server in grace period
lockd: spurious grace period reject?!
lockd: failed to reclaim lock for pid 2508 (errno -37, status 4)
NLM: done reclaiming locks for host B
lockd: release host B

even though grace period is intended for lock reclamation. B/w after such 
invocation no files, corresponding to the notified clients, appear in 
/var/lib/nfs/sm/ on server for about 10 minutes, if I try locking from any of 
these notified clients, even though locking itself is ok. Locking from other 
clients generates files for them instantly.

As of the rest: simple concurrent lock tests from couple of clients work fine as 
well as server frees locks of rebooted clients.

I'm new to NFS an may be missing obvious things, but I've already spent several 
days googling around, but don't seem to find any solution.
Any help or guidance is highly appreciated. Thanks!

