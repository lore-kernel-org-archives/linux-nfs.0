Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:50095 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755540AbeAHDb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 7 Jan 2018 22:31:59 -0500
Received: from stefans-mbp.lan ([188.20.239.46]) by mail.gmx.com (mrgmx001
 [212.227.17.190]) with ESMTPSA (Nemesis) id 0MWCgz-1eNaXU3RXd-00XITS for
 <linux-nfs@vger.kernel.org>; Mon, 08 Jan 2018 04:31:57 +0100
From: =?utf-8?Q?Stefan_Gr=C3=BCnwald?= <stefan.g@gmx.at>
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: nfsidmap static translation
Message-Id: <F5A80696-4C98-4D1C-AEDE-952D9A40BE33@gmx.at>
Date: Mon, 8 Jan 2018 04:31:57 +0100
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I’m trying to setup a static user translation for my NFS share.
So far I set N in /sys/modules/nfs/parameters/nfs4_disable_idmapping and I put my static translation into /etc/idmapd.conf.
But it seems like nfsidmap doesn’t use that.

libnfsidmap includes a smaple code libtest.c.
When I try my static translation with that everything seems to work fine.
What I found out so far is that libtest.c also calls nfs4_gss_princ_to_ids before calling nfs4_name_to_uid.
This seems to make the difference.

Can anyone tell me if I have to do some changes in my configuration to make nfsidmap work like I want?
Or is it impossible to use the static user translation with nfsidmap?

Thanks,
Stefan