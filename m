Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:54841 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbZIBMYq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:24:46 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82COlxo010971
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:54:47 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82COlhj1843404
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:54:47 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82COk6W001021
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:24:47 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: trond.myklebust@netapp.com, bfields@fieldses.org, nfsv4@linux-nfs.org,
        ffilzlnx@us.ibm.com, agruen@suse.de, aneesh.kumar@linux.vnet.ibm.com,
        sfrench@us.ibm.com
Cc: linux-nfs@vger.kernel.org
Subject: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Wed,  2 Sep 2009 17:54:20 +0530
Message-Id: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch series implement POSIX ACL support for NFSV4 clients
using sideband protocol. The ACL support can be disabled/enabled
using -o noacl/-o acl mount option. The feature enables to
view and  modify POSIX acls from NFSv4 client.

-aneesh

