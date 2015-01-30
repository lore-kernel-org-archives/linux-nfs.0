Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751700AbbA3WgN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jan 2015 17:36:13 -0500
Message-ID: <54CC075C.9000301@RedHat.com>
Date: Fri, 30 Jan 2015 17:36:12 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.3.2 released.
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

As promised a new release of nfs-utils, just in time for this year's Connectathon.

Some of the highlights:

* mount.nfs will start the mount negations at with the V4.2. 
* rpc.gssd was basically reinvented and now uses libevent.
* Supported defaults have changed: IPv6 is on, rpc.svcgssd is off. 
* The mountstats command had been improved.
* Improvements in the systemd scripts.

As well as the numerous bug fixes.

The tarballs can be found in
  http://kernel.org/pub/linux/utils/nfs-utils/1.3.2/
or
  http://sourceforge.net/projects/nfs/files/nfs-utils/1.3.2

The change log is in
   http://kernel.org/pub/linux/utils/nfs-utils/1.3.2/1.3.2-ChangeLog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/1.3.2/

The git tree is at:
   git://linux-nfs.org/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
