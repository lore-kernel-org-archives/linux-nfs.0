Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754953Ab0LHTsR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Dec 2010 14:48:17 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oB8JmHgV023622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 8 Dec 2010 14:48:17 -0500
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id oB8JmHvW028874
	for <linux-nfs@vger.kernel.org>; Wed, 8 Dec 2010 14:48:17 -0500
Message-ID: <4CFFE100.8070100@RedHat.com>
Date: Wed, 08 Dec 2010 14:48:16 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: libnfsidmap-0.24 is available
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A new version of libnfsidmap is now available from
http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/libnfsidmap-0.24.tar.gz

Changes since libnfsidmap-0.23

Added autogen.sh which runs all the autoconfig scripts
Added a .gitignore file

>From Bryan Schumaker <bjschuma@netapp.com>
Added nfs4_owner interfaces which are used by the new nfsidmap program

steved.

