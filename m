From: Steve Dickson <SteveD@redhat.com>
Subject: Question: why only 8 security flavors per export??
Date: Fri, 04 Dec 2009 11:11:19 -0500
Message-ID: <4B1934A7.90801@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150AbZLDQLO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 11:11:14 -0500
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nB4GBKQE023530
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 4 Dec 2009 11:11:21 -0500
Received: from badhat.bos.devel.redhat.com (vpn-243-208.phx2.redhat.com [10.3.243.208])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id nB4GBKuY028790
	for <linux-nfs@vger.kernel.org>; Fri, 4 Dec 2009 11:11:20 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Why are only 8 (SECFLAVOR_COUNT) security flavors allow 
per export when 13 security flavors are supported 
(see flav_map[] in  nfs/exports.c)? 
  
I'm trying to create an export that supports all possible
security flavors and its erroring out with "mountd: more than 
8 security flavors on an export"

steved.

