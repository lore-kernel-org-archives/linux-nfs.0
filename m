Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbaHHRGa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Aug 2014 13:06:30 -0400
Message-ID: <53E5038D.2050003@RedHat.com>
Date: Fri, 08 Aug 2014 13:06:21 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: libtirpc <libtirpc-devel@lists.sourceforge.net>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: ANNOUNCE: libtirpc-0.2.5 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

The 0.2.5 version of libtirpc has just been released. 

In this release there are the usual bug fixes and 
enhancements as well as a new debugging infrastructure
that enables the existing debugging code, dynamically, 
via the new the libtirpc_set_debug() interface.

The existing debugging code is pretty rough and 
needs so work but at least it now usable

The release notes detailing the bug fixes are at:

http://sourceforge.net/projects/libtirpc/files/libtirpc/0.2.5/ReleaseNotes.txt

The tarball can be found at:

  http://sourceforge.net/projects/libtirpc/files/libtirpc/0.2.5/libtirpc-0.2.5.tar.bz2

The git tree is at:
   git://git.infradead.org/~steved/libtirpc.git

steved.
