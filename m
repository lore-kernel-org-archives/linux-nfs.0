Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320Ab0IAQGi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Sep 2010 12:06:38 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o81G6bVY008475
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 1 Sep 2010 12:06:37 -0400
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o81G6bQb023397
	for <linux-nfs@vger.kernel.org>; Wed, 1 Sep 2010 12:06:37 -0400
Message-ID: <4C7E7A0C.70402@RedHat.com>
Date: Wed, 01 Sep 2010 12:06:36 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Updated pNFS Developmental kernel repository
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've updated the Fedora pNFS development repository to include the
Fedora 13, 14 and Devel kernels that have the latest pNFS bits:

    Tag: pnfs-all-2.6.35-2010-08-24     for Fedora 13 and 14 kernels
    Tag: pnfs-all-2.6.36-rc3-2010-08-30 for Devel/f15 kernels

(Note: there are also kernel-debuginfo and kernel-devel rpms for people who 
use things like systemtap probes and crash).

I've also updated the pNFS-enabled nfs-utils in all three releases. 

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.
