Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay2.lrz-muenchen.de ([129.187.254.102]:57891 "EHLO
	mailrelay2.lrz-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933331Ab0JSNPV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Oct 2010 09:15:21 -0400
Received: from st-brauchle.localnet ([129.187.109.181] [129.187.109.181]) by mailout.lrz-muenchen.de with ESMTP for linux-nfs@vger.kernel.org; Tue, 19 Oct 2010 15:00:08 +0200
From: Joschi Brauchle <joschi.brauchle@tum.de>
To: linux-nfs@vger.kernel.org
Subject: RPCIOD constantly taking 10-20% CPU, X hangs (in NFSv4 Environment)
Date: Tue, 19 Oct 2010 15:00:07 +0200
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201010191500.07799.joschi.brauchle@tum.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello everyone,

I have a problem with a OpenSuSE 11.3 box that I reported here: 
https://bugzilla.novell.com/show_bug.cgi?id=644880

I thought I'd post this to the NFS mailing list, as I did not get a response 
from Novell yet and the problem keeps us from upgrading about 100 machines 
from OpenSuSE11.1 to 11.3. 
-----------------------

I have the following problem with Opensuse 11.3, x86_64 in an NFSv4 
environment:

Mostly in the morning when I return to the box (it's running idle all night), 
the X server hangs and 'top' shows 'rpciod/0' taking between 10-20% cpu
constantly. A 'reboot' fails as stopping the 'automount' service fails due to 
my home (NFSv4 mount) being busy. 

Sometimes the X server freezes with the same symptoms even randomly during 
work, but mostly it seems to happen when the session is idle at night.

I'm not very experienced in debugging a problem like this, so I definitely 
need instructions on how to get more information. Here is the information I 
have at hand:
-----------------------
'uname -a' on the Opensuse 11.3 box:
Linux <hostname> 2.6.34.7-0.3-desktop #1 SMP PREEMPT 2010-09-20 15:27:38 +0200 
x86_64 x86_64 x86_64 GNU/Linux
-----------------------
'mount' returns the following line on my home:
192.168.109.3:/home/staff/<username> on /home/<username> type nfs4 
(rw,rsize=32768,wsize=32768,sec=krb5,sloppy,addr=192.168.109.3,clientaddr=192.168.109.72)

There are no other NFSv4 mounts.
-----------------------
I get a LOT of these messages in '/var/log/messages':
Sep 28 18:30:58 <hostname> kernel: [117887.140931] NFS: v4 server returned a 
bad sequence-id error on an unconfirmed sequence ffff88007babd828!
-----------------------

The NFS server is running SLES 10SP3 in a two-node Heartbeat cluster 
configuration with a shared IP (192.168.109.3), serving NFSv3 and NFSv4 (with 
Kerberos/GSS Security). 
/etc/exports on the server contains:
-----------------------
# NFSv4 entries (with Kerberos and GSS Security): 
/export          gss/krb5(rw,fsid=0,no_all_squash,async,no_subtree_check)

We have about 40 OpenSuse 11.1 clients getting their homes from this server, 
they are all running fine without problems for several months. It seems to be 
a problem in the kernel of 11.3.

I also tried the latest kernel 2.6.36.rc7 available from the OpenSuse 
Buildservice. The problem persists, but the process that is hanging here is 
called "kworker".

By now I switched to the debug kernel 2.6.34.7. As I said, just let me know 
what more debug info is needed and how to obtain it. Also I have not found a 
way to reproduce or trigger the problem manually. I will try to create more 
NFSv4 traffic to see if I can reproduce the problem.

Thanks!
