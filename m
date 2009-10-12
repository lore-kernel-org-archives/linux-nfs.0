From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 0/3] nfsmount.conf: New variables that explicitly set default
 (Release 2)
Date: Mon, 12 Oct 2009 17:33:46 -0400
Message-ID: <4AD3A0BA.3080104@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933212AbZJLVeZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2009 17:34:25 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9CLXxKK011346
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2009 17:34:00 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-119.rdu.redhat.com [10.11.10.119])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9CLXw0f032630
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2009 17:33:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is an update to my previous patch that allow the setting
of both the protocol version and network version from the 
mount configuration file. Here is the original justification:

    http://marc.info/?l=linux-nfs&m=125511238831199&w=2

The changes are:
   * Broken up the patch into three different patch with 
     of making it easier to review.

   * Changed the mount configuration variables from default_nfsvers
     and default_proto to defaultvers and defaultproto.


Comments?

steved.
