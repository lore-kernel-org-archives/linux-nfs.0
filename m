Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rhcavspool01.kulnet.kuleuven.be ([134.58.240.193]:44599 "EHLO
	cavspool01.kulnet.kuleuven.be" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756066AbaGANLH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 09:11:07 -0400
Received: from cavuit01.kulnet.kuleuven.be (rhcavuit01.kulnet.kuleuven.be [134.58.240.129])
	by cavspool01.kulnet.kuleuven.be (Postfix) with ESMTP id 4D5EDBBC6
	for <linux-nfs@vger.kernel.org>; Tue,  1 Jul 2014 15:04:13 +0200 (CEST)
Received: from icts-p-smtps-1.cc.kuleuven.be (icts-p-smtps-1e.kulnet.kuleuven.be [134.58.240.33])
	by cavuit01.kulnet.kuleuven.be (Postfix) with ESMTP id 7A16720004
	for <linux-nfs@vger.kernel.org>; Tue,  1 Jul 2014 15:03:41 +0200 (CEST)
Received: from hydrogen.esat.kuleuven.be (hydrogen.esat.kuleuven.be [134.58.56.153])
	by icts-p-smtps-1.cc.kuleuven.be (Postfix) with ESMTP id 79F974075
	for <linux-nfs@vger.kernel.org>; Tue,  1 Jul 2014 15:03:41 +0200 (CEST)
Received: from lucifer.esat.kuleuven.be (lucifer.esat.kuleuven.be [10.33.138.9])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by hydrogen.esat.kuleuven.be (Postfix) with ESMTP id 7564F48002
	for <linux-nfs@vger.kernel.org>; Tue,  1 Jul 2014 15:03:41 +0200 (CEST)
Message-ID: <53B2B1AD.4080507@esat.kuleuven.be>
Date: Tue, 01 Jul 2014 15:03:41 +0200
From: Rik Theys <Rik.Theys@esat.kuleuven.be>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS server caches client mount permissions?
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We use NFS4 to export data to other clients. The exports file has the 
directories exported to netgroups, for example:

/export		@nfs(rw,async,no_subtree_check,fsid=0)
/export/data1	@nfs(rw,async,no_subtree_check)
/export/data2	@nfs(rw,async,no_subtree_check)

If we forget to add a new client to the netgroup, the server rejects the 
mount from the client (as it should). But when we then add the client to 
the netgroup it can take up to 15 minutes for the server to accept the 
new client.

Using 'getent netgroup nfs' on the server immediately shows the new 
entry of the client.

Running exportfs -rv to reload the exports also doesn't help.

Does nfsd cache mount access (rejections) somewhere? How can I 
flush/tune this cache? Preferably without restarting the NFS server as 
that causes a 90s interruption due to the grace period.

Regards,

Rik

-- 
Rik Theys
System Engineer
KU Leuven - Dept. Elektrotechniek (ESAT)
Kasteelpark Arenberg 10 bus 2440  - B-3001 Leuven-Heverlee
+32(0)16/32.11.07
----------------------------------------------------------------
<<Any errors in spelling, tact or fact are transmission errors>>
