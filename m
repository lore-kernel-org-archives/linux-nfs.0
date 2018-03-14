Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36571 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751362AbeCNOhF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Mar 2018 10:37:05 -0400
From: Steve Dickson <SteveD@RedHat.com>
Subject: ANNOUNCE: libtirpc-1.0.3 released.
To: libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <0d0f33d2-079c-fcd1-0bba-a85d166a516c@RedHat.com>
Date: Wed, 14 Mar 2018 10:37:04 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

The 1.0.3 version of libtirpc has just been release.

In this release there a couple of bug fixes, code
was added to avoid choosing reserve ports at
listening ports, close a memory leaks which fixed a CVE

The tarball:
   http://sourceforge.net/projects/libtirpc/files/libtirpc/1.0.3/libtirpc-1.0.3.tar.bz2

Release notes:
    http://sourceforge.net/projects/libtirpc/files/libtirpc/1.0.3/Release-1.0.3.txt

The git tree is at:
   git://linux-nfs.org/~steved/libtirpc


steved.
