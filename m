Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966309AbeEXRad (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 May 2018 13:30:33 -0400
From: Steve Dickson <SteveD@RedHat.com>
Subject: ANNOUNCE: nfs-utils-2.3.2 released.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-ID: <ae4d2ce7-ca45-9f65-54a2-bbb44ca4c34d@RedHat.com>
Date: Thu, 24 May 2018 13:30:32 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

nfs-utils-2.3.2 has just been released.

Along with the usual bug fixes:
   * libjunction support was added.
   * The nfsref command was added that administers junctions
   * Most compile warnings are now fatal errors.
   * The nfsconf command was added that dump, gets and
     test setting in /etc/nfs.conf

The tarballs can be found in
  https://www.kernel.org/pub/linux/utils/nfs-utils/2.3.2/
or
  http://sourceforge.net/projects/nfs/files/nfs-utils/2.3.2

The change log is in
   https://www.kernel.org/pub/linux/utils/nfs-utils/2.3.2/2.3.2-Changelog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/2.3.2/

The git tree is at:
   git://linux-nfs.org/~steved/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
