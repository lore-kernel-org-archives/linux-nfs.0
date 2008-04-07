From: Vince Busam <vbusam@google.com>
Subject: Default supported enctypes in rpc.gssd
Date: Mon, 07 Apr 2008 14:33:14 -0700
Message-ID: <47FA931A.8080602@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:52402 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765AbYDGVcy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2008 17:32:54 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m37LWpC4022427
	for <linux-nfs@vger.kernel.org>; Mon, 7 Apr 2008 22:32:51 +0100
Received: from dig.smo.corp.google.com (dig.smo.corp.google.com [172.29.60.89])
	by zps77.corp.google.com with ESMTP id m37LWoD7030659
	for <linux-nfs@vger.kernel.org>; Mon, 7 Apr 2008 14:32:50 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there a reason the patch to use kernel supported enctypes from
http://www.citi.umich.edu/projects/nfsv4/linux/nfs-utils-patches/1.1.1-1/nfs-utils-1.1.1-007-gssd_use_kernel_supported_enctypes.dif 

wasn't included in the 1.1.2 release?  It would be nice to at least 
increase the default list to match what this patch does ("1,3,2", adding 
ENCTYPE_DES_CBC_MD4 & ENCTYPE_DES_CBC_MD5).

Vince
