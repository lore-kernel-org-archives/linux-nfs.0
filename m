Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49694 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755311AbdLTQtT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Dec 2017 11:49:19 -0500
From: Steve Dickson <SteveD@RedHat.com>
Subject: ANNOUNCE: nfs-utils-2.3.1 released.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-ID: <1a56bb72-cc10-ba74-2b04-4df588804ef5@RedHat.com>
Date: Wed, 20 Dec 2017 11:49:19 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

nfs-utils-2.3.1 has just been released.

The main reason for this release is the SONAME 
is changing on libnfsidmap library. The API is 
being tidied up so internal functions and variable
are no longer exposed. 

This should only cause pain for a couple of packages
which probably mean there will be some growing pains.

Down the road I would like to see no dependence on
this library so it can become an static library
internal to nfs-utils. 

The tarballs can be found in
  https://www.kernel.org/pub/linux/utils/nfs-utils/2.3.1/
or
  http://sourceforge.net/projects/nfs/files/nfs-utils/2.3.1

The change log is in
   https://www.kernel.org/pub/linux/utils/nfs-utils/2.3.1/2.3.1-Changelog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/2.3.1/

The git tree is at:
   git://linux-nfs.org/~steved/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.

