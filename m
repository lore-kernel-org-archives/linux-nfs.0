Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755846Ab2ENTQB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 15:16:01 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q4EJG1dX018357
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 14 May 2012 15:16:01 -0400
Received: from badhat.bos.devel.redhat.com (vpn-10-78.rdu.redhat.com [10.11.10.78])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q4EJG0hH012610
	for <linux-nfs@vger.kernel.org>; Mon, 14 May 2012 15:16:00 -0400
Message-ID: <4FB159DA.2070800@RedHat.com>
Date: Mon, 14 May 2012 15:15:38 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.2.6 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New Features in this release:
   * The addition the nfsdcld daemon
   * The addition of the osd_login script which is mandated by the
         pnfs-objects standard
   * The addition of -l option to rpcgssd to enforce legacy behaviour

As well as the usual assorted bug fixes...  

The tarball can only be found at Sourceforge.net since 
still unable to access ftp://ftp.kernel.org (I'm working
on it):
  http://sourceforge.net/projects/nfs

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log is also only on Sourceforge.net:
   http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.6/Changelog-1.2.6/download

steved.
