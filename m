Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37852 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbcDNTFH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Apr 2016 15:05:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1aqmZc-0002gV-RX
	for linux-nfs@vger.kernel.org; Thu, 14 Apr 2016 21:05:05 +0200
Received: from 209.117.222.196 ([209.117.222.196])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 21:05:04 +0200
Received: from ziemowit by 209.117.222.196 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 21:05:04 +0200
To: linux-nfs@vger.kernel.org
From: Ziemowit PIerzycki <ziemowit@pierzycki.com>
Subject: What is a 10.10.10.20-man process?
Date: Thu, 14 Apr 2016 19:01:25 +0000 (UTC)
Message-ID: <loom.20160414T205732-249@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a strange issue when NFS4 mounts to a Netapp filer freeze on my Linux 
KVMs.  Looking over few things I noticed a process "10.10.10.20-man" is in D 
state but I can't find anything information about it.  Mainly because 
10.10.10.20 is the IP of the filer and searching for "-man" is too generic.

Why would this process be frozen?

