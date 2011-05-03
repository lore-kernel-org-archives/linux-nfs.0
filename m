Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:46069 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab1ECP35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 11:29:57 -0400
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id CFA4BDA8
	for <linux-nfs@vger.kernel.org>; Tue,  3 May 2011 17:29:55 +0200 (MEST)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id B0698D6A
	for <linux-nfs@vger.kernel.org>; Tue,  3 May 2011 17:29:55 +0200 (MEST)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP3.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <T9cc3517b7083a9616116d4@ZITSWEEP3.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Tue, 3 May 2011 17:29:55 +0200
Received: from [131.169.185.68] (anahit.desy.de [131.169.185.68])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id 40D363E901
	for <linux-nfs@vger.kernel.org>; Tue,  3 May 2011 17:29:55 +0200 (MEST)
Message-ID: <4DC01F1A.9060305@desy.de>
Date: Tue, 03 May 2011 17:28:26 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pNFS and ipv6
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Dear friends,

are there plans to support IPv6 with pNFS ?

fs/nfs/nfs4filelayoutdev.c:325

         /* Currently only support ipv4 address */
         if (in4_pton(buf, rlen, (u8 *)&ip_addr, '-', &ipend) == 0) {
                 dprintk("%s: Only ipv4 addresses supported\n", __func__);
                 goto out_free;
         }


Regards,
    Tigran.
