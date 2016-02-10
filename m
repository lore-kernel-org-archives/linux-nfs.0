Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from MG2.fis.unical.it ([192.167.201.9]:49505 "EHLO
	MG2.fis.unical.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbcBJMQ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2016 07:16:57 -0500
Received: from MG2.fis.unical.it (localhost.localdomain [127.0.0.1])
	by localhost (Email Security Appliance) with SMTP id C912C358C8B9_6BB27FBB
	for <linux-nfs@vger.kernel.org>; Wed, 10 Feb 2016 12:07:23 +0000 (GMT)
Received: from MB.fis.unical.it (MB.fis.unical.it [192.167.201.16])
	by MG2.fis.unical.it (Sophos Email Appliance) with ESMTP id 88EBF358C6C4_6BB27FBF
	for <linux-nfs@vger.kernel.org>; Wed, 10 Feb 2016 12:07:23 +0000 (GMT)
Message-ID: <1455106042.4536.21.camel@fis.unical.it>
Subject: Kernel crash in Centos 6.6
From: Fedele Stabile <fedele.stabile@fis.unical.it>
Reply-To: fedele.stabile@fis.unical.it
To: linux-nfs@vger.kernel.org
Date: Wed, 10 Feb 2016 13:07:22 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,
I have a kernel crash when I mount an NFS volume using RDMA transport.
On client and server is installed Centos 6.6 kernel 2.6.32
-504.8.1.el6.x86_64
I use nfs v4
The client hangs if I execute 
mount -t nfs -o rdma ib-server:/data /data
Server and client are connected throw Infiniband network and Qlogic
adapters.

Can you help me?
Fedele Stabile

