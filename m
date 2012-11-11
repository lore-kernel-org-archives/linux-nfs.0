Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179Ab2KKXib (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Nov 2012 18:38:31 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qABNcUwB009869
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sun, 11 Nov 2012 18:38:30 -0500
Received: from smallhat.bos.devel.redhat.com (vpn-11-117.rdu.redhat.com [10.11.11.117])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id qABNcTw5012179
	for <linux-nfs@vger.kernel.org>; Sun, 11 Nov 2012 18:38:30 -0500
Message-ID: <50A036F5.3060706@RedHat.com>
Date: Sun, 11 Nov 2012 18:38:29 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.2.7 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New Features in this release:
   * The nfsdcld daemon was replaced by the nfsdcltrack (which is
     enabled by default)

   * FedFS support was added to mountd.

As well as the usual assorted bug fixes...  

The tarballs can be found at
  http://kernel.org/pub/linux/utils/nfs-utils/1.2.7/
or
  http://sourceforge.net/projects/nfs

The change log is at 
   http://kernel.org/pub/linux/utils/nfs-utils/1.2.7/1.2.7-ChangeLog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.7/1.2.7-Changelog

The git tree is at:
   git://linux-nfs.org/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
