From: Anton Starikov <ant.starikov@gmail.com>
Subject: NFSv3/NFSv4 problem.
Date: Mon, 1 Mar 2010 16:01:42 +0100
Message-ID: <D27EC8DD-AD1C-432D-99FD-E4AB6C26D189@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:36363 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab0CAPBu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Mar 2010 10:01:50 -0500
Received: by fxm19 with SMTP id 19so803068fxm.21
        for <linux-nfs@vger.kernel.org>; Mon, 01 Mar 2010 07:01:48 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, 


my config is diskless NFSv3 nfsroot (+ some extra NFDSv3 mounts) and NFSv4 /home/* automount.
Centos 5.4, kernel 2.6.18-164.11.1.el5.

Periodically my nodes hangs, nothing appeared in the logs (remote syslog + netconsole).
Node is kind of alive, you can ping, some deamons (for example pbs_mom) reports that it's alive etc.
But anything which require FS access - frozen.

Another symptom, it looks like portmap doesn't answer. At lease if I try "rpcinfo -p node_name", then it ends with
"rpcinfo: can't contact portmapper: rpcinfo: RPC: Timed out"

In principal, this can have something with locking.
At least, I had to mount all my NFSv3 mounts with nolock, to reduce frequency of problem (nfsroot was nolock, obviously. but there are couple of extra v3 mounts, like /opt with extra software and RW directory for torque.

What can be a problem here?

What kind of information I have to collect from system to figure out what it real problem?

Anton. 