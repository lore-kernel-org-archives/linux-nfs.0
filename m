Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:44979 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385Ab0IIVqx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Sep 2010 17:46:53 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o89LkorF018678
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 9 Sep 2010 21:46:52 GMT
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by acsinet15.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id o895ujRQ031792
	for <linux-nfs@vger.kernel.org>; Thu, 9 Sep 2010 21:46:50 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFS over RDMA bug reports
Date: Thu, 9 Sep 2010 17:45:54 -0400
Message-Id: <65A8AD4C-41FE-49F3-899F-E5998AFDC647@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is kind of a general question.

We have some internal testing of client-side RH/OEL 5 NFS over RDMA that has turned up some bugs, for example:

  https://bugs.openfabrics.org/show_bug.cgi?id=2076

Though it's assigned, it looks like it's been around for about 3 months with no activity.  Is filing NFS/RDMA client side bugs with openfabrics the best/only way to document them and get them addressed?  Are these scrubbed regularly?  What resources are available to address these problems?

There was some talk at Connectathon about having all NFS/RDMA bugs reported as above.  However, though OFED packages are required to run NFS/RDMA on EL5 kernels, the crash documented in the above bug is in the kernel NFS client, and that appears to be unmodified EL5.4.  OFED provides only the RDMA kernel modules.  Are they triaging these issues and reporting them back to Red Hat?

What resources are available to address client-side upstream NFS/RDMA issues?

I'm not trying to point fingers, just wondering what the mechanisms are to get these kind of problems resolved.  If there aren't any, I'd like to see what can be done to get something in place.

-- 
chuck[dot]lever[at]oracle[dot]com




