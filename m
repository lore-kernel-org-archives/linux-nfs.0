Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbcFJOoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jun 2016 10:44:16 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4D676C004F7C
	for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 14:44:15 +0000 (UTC)
Received: from [10.10.49.99] (vpn-49-99.rdu2.redhat.com [10.10.49.99])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u5AEiEs2031353
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 10:44:15 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "linux-nfs list" <linux-nfs@vger.kernel.org>
Subject: blocklayout destruction and device id cache on error
Date: Fri, 10 Jun 2016 10:44:29 -0400
Message-ID: <C7D37F9A-2A49-44E7-A4BB-7B06AAEE00C7@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

For SCSI devices, the last placement of the device is going to try to
unregister the client's SCSI reservation, and this process allocates memory
somewhere in the sg code and might sleep.  Usually, that's no problem as the
last placement is the client's which is done when the the nfs4_server is
destroyed.

However, a session error can cause the client to purge the client's devices
and then destroy layouts, which means that for blocklayouts we will do the
final put of the device under a spinlock in ext_tree_remove() which is part
of the accounting bits for determining which page IO belongs to which
device, and it might sleep holding that lock.

A really lazy way to fix this would be to destroy the layouts before
purging the client's devices, like:

 pnfs_destroy_all_layouts(struct nfs_client *clp)
 {
        nfs4_deviceid_mark_client_invalid(clp);
-       nfs4_deviceid_purge_client(clp);

        pnfs_destroy_layouts_byclid(clp, false);
+       nfs4_deviceid_purge_client(clp);
 }

.. but, I am not sure if that poses a problem for any of the other layout
types.

It could be argued that if we can't ever do the final placement from
ext_tree_remove(), why should we bother to reference the device from there
in the first place?

Any thoughts?

Ben
