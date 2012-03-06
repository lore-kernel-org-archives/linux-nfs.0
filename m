Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:34046 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965128Ab2CFKvo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 05:51:44 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by rcsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q26AphrA003841
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 10:51:43 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q26ApgWU022253
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 10:51:42 GMT
Received: from abhmt107.oracle.com (abhmt107.oracle.com [141.146.116.59])
	by acsmt357.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q26Apg7k015092
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 04:51:42 -0600
Date: Tue, 6 Mar 2012 13:51:35 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: re: NFS: Add a client-side function to display NFS file handles
Message-ID: <20120306105134.GA1048@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Chuck Lever,

This is a semi-automatic email about new static checker warnings.

The patch 20d27e929fb4: "NFS: Add a client-side function to display 
NFS file handles" from Mar 1, 2012, leads to the following Smatch 
complaint:

fs/nfs/inode.c:1061 _nfs_display_fhandle()
	 warn: variable dereferenced before check 'fh' (see line 1061)

fs/nfs/inode.c
  1060	
  1061		if (fh->size == 0 || fh == NULL) {
                    ^^^^^^^^         ^^^^^^^^^^
                   dereference          check

  1062			printk(KERN_DEFAULT "%s at %p is empty\n", caption, fh);
  1063			return;

regards,
dan carpenter

