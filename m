Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122Ab1IXMz6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Sep 2011 08:55:58 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8OCtwCN001080
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 24 Sep 2011 08:55:58 -0400
Received: from badhat.bos.devel.redhat.com (vpn-8-90.rdu.redhat.com [10.11.8.90])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8OCtvu3000869
	for <linux-nfs@vger.kernel.org>; Sat, 24 Sep 2011 08:55:58 -0400
Message-ID: <4E7DD35D.9080800@RedHat.com>
Date: Sat, 24 Sep 2011 08:55:57 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.2.5 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

New Features in this release:

   * With the addition of the blkmapd daemon, the client 
     now supports every pNFS layout type. 

   * The usual assorted bug fixes. 

The tarball can only be found at Sourceforge.net since 
master.kernel.org is still down:

  http://sourceforge.net/projects/nfs

[ Maybe we should start thinking about putting the rpms on linux-nfs.org?? ]

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log is also only on Sourceforge.net:

http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.5/Changelog-1.2.5/download

steved.
