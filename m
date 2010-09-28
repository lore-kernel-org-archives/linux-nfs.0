Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63812 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753800Ab0I1M4F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 08:56:05 -0400
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8SCu5FG004849
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 28 Sep 2010 08:56:05 -0400
Received: from badhat.bos.devel.redhat.com (vpn-224-161.phx2.redhat.com [10.3.224.161])
	by int-mx03.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o8SCu4Ss031650
	for <linux-nfs@vger.kernel.org>; Tue, 28 Sep 2010 08:56:04 -0400
Message-ID: <4CA1E5E4.1070404@RedHat.com>
Date: Tue, 28 Sep 2010 08:56:04 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.2.3 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

New Features in this release:

   * Both Client and server IPv6 support is available with the 
     --enable-ipv6 configuration flag (which is on by default)

   * NFSoverRDMA mount support.

   * A large number of bug fixes.

The tarball can be found at:

  http://www.kernel.org/pub/linux/utils/nfs/
  http://sourceforge.net/projects/nfs

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log:

http://www.kernel.org/pub/linux/utils/nfs/ChangeLog-nfs-utils-1.2.3

steved.
