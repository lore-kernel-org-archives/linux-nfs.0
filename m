Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34718 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932648AbdJ3Rwl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 13:52:41 -0400
From: Steve Dickson <SteveD@RedHat.com>
Subject: ANNOUNCE: nfs-utils-2.2.1 released.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-ID: <ae92162b-6999-249d-2f70-95a3c6a1174d@RedHat.com>
Date: Mon, 30 Oct 2017 13:52:40 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

nfs-utils-2.2.1 has just been released.

Along with usual bug fixes and improvements, the libnfsidmap 
code has been rolled into the nfs-utils git tree and is now
being built as part of nfs-utils. 

The upstream git tree for libnfsidmap no longer exists so 
all patches for the libnfsidmap code must be relative 
to the code under support/nfsidmap in the nfs-utils 
git tree.

I would like to thank Justin Mitchell for doing most
of this work... 

The tarballs can be found in
  https://www.kernel.org/pub/linux/utils/nfs-utils/2.2.1/
or
  http://sourceforge.net/projects/nfs/files/nfs-utils/2.2.1

The change log is in
   https://www.kernel.org/pub/linux/utils/nfs-utils/2.2.1/2.2.1-Changelog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/2.2.1/

The git tree is at:
   git://linux-nfs.org/~steved/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.

