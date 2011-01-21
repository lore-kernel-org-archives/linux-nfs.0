Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nospam.livetext.com ([64.94.43.179]:55415 "EHLO
	nospam.livetext.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696Ab1AUXkh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Jan 2011 18:40:37 -0500
Received: from mail-fx0-f51.google.com (mail-fx0-f51.google.com [209.85.161.51])
	by nospam.livetext.com (Postfix) with ESMTP id 1387F246DCF
	for <linux-nfs@vger.kernel.org>; Fri, 21 Jan 2011 17:06:46 -0600 (CST)
Received: by fxm5 with SMTP id 5so2389427fxm.10
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jan 2011 15:06:45 -0800 (PST)
Date: Fri, 21 Jan 2011 17:06:45 -0600
Message-ID: <AANLkTi=R_j3_hZ-7RpSn0_Mee43nU0njPRBSn=DiEf8R@mail.gmail.com>
Subject: releasing space after rapid grwoth
From: Max Veprinsky <max.veprinsky@livetext.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello all,

I'm trying to reclaim disk space on stable storage which was consumed
by a crashed apache process at a rate of ~100GB/hour. This issue has
happened a few times before and normally resolved by discovering a
.nfsXXXXX file, stopping the process on the the application server
that was holding the file. Sometimes the used filespace is recovered
quickly without manual intervention, other times I had to delete the
.nfsXXXX file manually.

Last time this happened 3 TB of disk space was consumed and no
.nfsXXXX file of that size was discovered, nor. I dismounted all of
the volumes from the clients 1/2 of the space was recovered.

showmount shows clients connected but there are no network nfs
connections open to any client. I have not restarted nfs server
service fearing that the used space would not be recovered.

Any suggestion greatly appreciated

Regards,
-- Max
