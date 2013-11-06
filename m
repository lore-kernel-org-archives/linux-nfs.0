Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756343Ab3KFMH4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Nov 2013 07:07:56 -0500
Message-ID: <527A3152.3040202@RedHat.com>
Date: Wed, 06 Nov 2013 07:08:50 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.2.9 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some of the new features in this release:
   * Both nfsiostat and mountstats are now Python 3 compatible 
   * A number of improvements in the parsing of /etc/nfsmount.conf
   * NFS v2 is no longer enable on the server by default
   * NFS v2 is no longer negotiated on mounts
   * A large number or rpc.gssd changes including working
     with the latest gss-proxy release. 

As well as the usual assorted bug fixes...  

The tarballs can be found at
  http://kernel.org/pub/linux/utils/nfs-utils/1.2.9/
or
  http://sourceforge.net/projects/nfs

The change log is at 
   http://kernel.org/pub/linux/utils/nfs-utils/1.2.9/1.2.9-ChangeLog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.9/1.2.9-Changelog

The git tree is at:
   git://linux-nfs.org/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
