Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:64417 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768Ab1IVRvY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 13:51:24 -0400
Date: Thu, 22 Sep 2011 13:51:17 -0400
From: Leo Chan <admin@kzeouki.com>
To: linux-nfs@vger.kernel.org
Subject: Read Only Issue from RHEL 6
Message-ID: <20110922175117.GD32034@qccos6.kze.local>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I want to submit a possible bug report that not able to get mount RW from RHEL 6.0. (RO only) We are able to mount RW  from a folder with symbolic link pointing to the mount point. But not mounting directly at the folder. Please let me know if you need further information.

RHEL 5.6 appears to be working fine. 


NFS Server.
Scientific Linux release 6.0 (Carbon) 
2.6.32-131.6.1.el6.x86_64
nfs-utils-lib-1.1.5-1.el6.x86_64
Export list:
/rhel/repo *
/rhel      *
/kickstart *

Working. Able to RW
Red Hat Enterprise Linux Server release 5.6 (Tikanga)
2.6.18-238.el5 
nfs-utils-lib-1.0.8-7.6.el5

RO Only, unless mounting on folder with symbolic link that points to /rhel/repo on server.
Red Hat Enterprise Linux Server release 6.0 (Santiago)
 2.6.32-71.18.2.el6.x86_64
nfs-utils-1.2.2-7.el6.x86_64

