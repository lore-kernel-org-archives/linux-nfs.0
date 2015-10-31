Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbbJaTvz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Oct 2015 15:51:55 -0400
From: Steve Dickson <SteveD@redhat.com>
Subject: ANNOUNCE: libtirpc-1.0.1 released.
To: libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <56351BDA.1090500@RedHat.com>
Date: Sat, 31 Oct 2015 15:51:54 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

The 1.0.1 version of libtirpc has just been release.

In this release the SONAME has been changed to 3.0.0 to
reflect a number of changes in the API. Those changes 
were needed to make the Linux version of libtirpc 
more compatible with other implementations  

The is also a number of bug fixes including fixing 
several memory leaks. 

The tarball:
   http://sourceforge.net/projects/libtirpc/files/libtirpc/1.0.1/libtirpc-1.0.1.tar.bz2

Release notes:
    http://sourceforge.net/projects/libtirpc/files/libtirpc/1.0.1/Release-0.3.2.txt

The git tree is at:
   git://linux-nfs.org/~steved/libtirpc


steved.
