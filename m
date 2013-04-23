Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755006Ab3DWLCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 07:02:06 -0400
Message-ID: <51766A2D.8060202@RedHat.com>
Date: Tue, 23 Apr 2013 07:02:05 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.2.8 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some of the new features in this release:
   * rpc.gssd now uses GSS-Proxy when available.

   * A number of other bug fixes/enhances in the GSS code.

   * -V flag was added to rpc.nfsd to make it easier to enable
      NFSD v4.1 in the server

As well as the usual assorted bug fixes...  

The tarballs can be found at
  http://kernel.org/pub/linux/utils/nfs-utils/1.2.8/
or
  http://sourceforge.net/projects/nfs

The change log is at 
   http://kernel.org/pub/linux/utils/nfs-utils/1.2.8/1.2.8-ChangeLog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.8/1.2.8-Changelog

The git tree is at:
   git://linux-nfs.org/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
