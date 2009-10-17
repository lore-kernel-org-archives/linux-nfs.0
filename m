Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbZJQNhA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Oct 2009 09:37:00 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9HDb5Kd011036
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2009 09:37:05 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-234.rdu.redhat.com [10.11.10.234])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9HDb4BO003303
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2009 09:37:04 -0400
Message-ID: <4AD9C871.3000400@RedHat.com>
Date: Sat, 17 Oct 2009 09:36:49 -0400
From: Steve Dickson <SteveD@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfsmount.conf: New variables that explicitly set default
 (Release 3)
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here is an update to my previous patch that allow the setting
of both the protocol version and network version from the 
mount configuration file. Here is the original justification:

    http://marc.info/?l=linux-nfs&m=125511238831199&w=2

In this release two global variables are used to keep 
the default values set in the configuration file. These
values are then used to initialize the values used in
the server negotiation. 

This patch set can be found on the 'mntconf_v3' branch
on my experimental git tree:
    git://linux-nfs.org/nfs-utils-exp


Comments?

steved.
