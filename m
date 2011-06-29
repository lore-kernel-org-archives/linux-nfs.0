Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32158 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751921Ab1F2OpQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jun 2011 10:45:16 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5TEjGuF005345
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 10:45:16 -0400
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p5TEjF7U000506
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 10:45:16 -0400
Message-ID: <4E0B3A7B.9080006@RedHat.com>
Date: Wed, 29 Jun 2011 10:45:15 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.2.4 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
