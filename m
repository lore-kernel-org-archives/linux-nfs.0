From: Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
Subject: portmap -> map db entirely in filesystem
Date: Tue, 13 May 2008 21:58:31 +0200
Message-ID: <20080513195831.GA18915@nibiru.local>
Reply-To: weigelt-EU+a56NjgY8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from s15216962.onlinehome-server.info ([217.160.22.205]:41616 "EHLO
	s15216962.onlinehome-server.info" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932109AbYEMUPo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 May 2008 16:15:44 -0400
Received: (from uucp@localhost)
	by s15216962.onlinehome-server.info (8.13.3/8.13.3) with UUCP id m4DJxQD7010213
	for linux-nfs@vger.kernel.org; Tue, 13 May 2008 21:59:26 +0200
Received: (from weigelt@localhost)
	by nibiru.metux.de (8.12.10/8.12.10) id m4DJwV8d024636
	for linux-nfs@vger.kernel.org; Tue, 13 May 2008 21:58:31 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi folks,


while working on portmap, I was thinking about moving the 
entire mapping table to the filesystem: one file per record.

Benefits:

* allows much simpler code: no internal maptable and load/store
  logic - just simple file IO (even limited to REST)
* external programs can directly manipulate the map db, w/o 
  goint through portmap itself
* several portmap's (eg. for serving on separate sockets or 
  different security domains) can easily share the same map.
* less process memory consumption of portmap (on larger maps)

Drawbacks:

* a bit slower, more IO traffic
* we have to rethink chroot'ing


What do you think about this ?


cu  
-- 
---------------------------------------------------------------------
 Enrico Weigelt    ==   metux IT service - http://www.metux.de/
---------------------------------------------------------------------
 Please visit the OpenSource QM Taskforce:
 	http://wiki.metux.de/public/OpenSource_QM_Taskforce
 Patches / Fixes for a lot dozens of packages in dozens of versions:
	http://patches.metux.de/
---------------------------------------------------------------------
