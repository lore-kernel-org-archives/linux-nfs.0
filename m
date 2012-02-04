Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44431 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664Ab2BDRcI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Feb 2012 12:32:08 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q14HW8VV015475
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 4 Feb 2012 12:32:08 -0500
Received: from badhat.bos.devel.redhat.com (vpn-8-135.rdu.redhat.com [10.11.8.135])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q14HW7I5027829
	for <linux-nfs@vger.kernel.org>; Sat, 4 Feb 2012 12:32:07 -0500
Message-ID: <4F2D6B97.6050102@RedHat.com>
Date: Sat, 04 Feb 2012 12:32:07 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: pNFS: Single Node pNFS Server
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

To help with the testing of pNFS clients, I making 
available a single node pNFS server (the  pnfsd-lexp 
branch of Benny's git tree) in Fedora based kernel 
and nfs-utils RPMs. This server only supports file layouts. 

Your need to be running a Fedora 16 to use these RPMs.
The RPMs are in a yum repository. Download this repo:

   http://steved.fedorapeople.org/pnfs.repo
and then do a yum update on a F16 machine.

Or you can access the RPMs directly at 
    http://steved.fedorapeople.org/repos/pnfs/devel/

The patches used to create the RPMs ar at:
    http://steved.fedorapeople.org/repos/pnfs/devel/pnfsd-3.3.0-0.rc2.git1.1.patch
    http://steved.fedorapeople.org/repos/pnfs/devel/pnfs-export-1.2.5-11.patch

Happy hunting! 

steved.



