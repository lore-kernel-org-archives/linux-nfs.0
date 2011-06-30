Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115Ab1F3PXB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 11:23:01 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5UFN1V7006026
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 11:23:01 -0400
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p5UFN0N3006937
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 11:23:01 -0400
Message-ID: <4E0C94D4.50205@RedHat.com>
Date: Thu, 30 Jun 2011 11:23:00 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.2.4 re-released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I just make a re-release of 1.2.4 this that corrects the mount problem.
Again, my apologies for not catching this problem before the release.
Its something I will avoid in the feature...  

New Features in this release:

   * Added the --enable-libmount-mount configuration 
     flag that enables the mount command to use the new
     libmount code.

   * A large number of bug fixes.

The tarballs can be found at:

  http://www.kernel.org/pub/linux/utils/nfs/
  http://sourceforge.net/projects/nfs

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log:

http://www.kernel.org/pub/linux/utils/nfs/ChangeLog-nfs-utils-1.2.4

steved.
