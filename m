Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755228AbaCYXCY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 19:02:24 -0400
Message-ID: <5331AA71.6090702@RedHat.com>
Date: Tue, 25 Mar 2014 12:10:25 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.3.0 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The majority in this release is bug fixes can clean up, 
but the features were added:

* systemd units 
* New arguments were add to number daemon for 
  easy of configuration
* IPv6 supported with raw address to exportfs

The tarballs can be found at
  http://kernel.org/pub/linux/utils/nfs-utils/1.3.0/
or
  http://sourceforge.net/projects/nfs

The change log is at 
   http://kernel.org/pub/linux/utils/nfs-utils/1.3.0/1.3.0-ChangeLog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/1.3.0/3.0-Changelog

The git tree is at:
   git://linux-nfs.org/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
