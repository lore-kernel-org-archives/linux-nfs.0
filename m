From: Tom H <tom-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Subject: kernel: BUG: soft lockup - CPU#5 stuck for 11s! [nfsd:20540]
Date: Sat, 24 Jul 2010 16:58:09 +0100
Message-ID: <4C4B0D91.3080207@limepepper.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from april.london.02.net ([87.194.255.143]:39160 "EHLO
	april.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619Ab0GXP6S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jul 2010 11:58:18 -0400
Received: from [192.168.1.64] (87.194.12.203) by april.london.02.net (8.5.124.03)
        id 4C1F983E00F70E29 for linux-nfs@vger.kernel.org; Sat, 24 Jul 2010 16:58:16 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

Has anyone any suggesions on what these messages might mean;

# grep BUG /var/log/messages*
/var/log/messages:Jul 23 03:18:21 server111 kernel: BUG: soft lockup - 
CPU#5 stuck for 11s! [nfsd:20540]
/var/log/messages:Jul 23 03:22:09 server111 kernel: BUG: soft lockup - 
CPU#1 stuck for 15s! [nfsd:20545]
/var/log/messages:Jul 23 03:24:21 server111 kernel: BUG: soft lockup - 
CPU#1 stuck for 24s! [nfsd:20546]

There were associated with a period of high load and poor performance on 
the NFS server.

Thanks
Tom







there were quite a few more...
/var/log/messages:Jul 23 03:29:17 server111 kernel: BUG: soft lockup - 
CPU#2 stuck for 14s! [nfsd:20552]
/var/log/messages:Jul 23 03:30:38 server111 kernel: BUG: soft lockup - 
CPU#6 stuck for 10s! [nfsd:20544]
/var/log/messages:Jul 23 03:30:58 server111 kernel: BUG: soft lockup - 
CPU#6 stuck for 12s! [nfsd:20540]
/var/log/messages:Jul 23 03:31:22 server111 kernel: BUG: soft lockup - 
CPU#3 stuck for 23s! [nfsd:20545]
/var/log/messages:Jul 23 03:31:33 server111 kernel: BUG: soft lockup - 
CPU#6 stuck for 10s! [nfsd:20549]
/var/log/messages:Jul 23 03:31:43 server111 kernel: BUG: soft lockup - 
CPU#5 stuck for 10s! [nfsd:20541]
/var/log/messages:Jul 23 03:32:30 server111 kernel: BUG: soft lockup - 
CPU#7 stuck for 20s! [nfsd:20548]
/var/log/messages:Jul 23 03:35:14 server111 kernel: BUG: soft lockup - 
CPU#1 stuck for 13s! [nfsd:20541]
/var/log/messages:Jul 23 03:37:12 server111 kernel: BUG: soft lockup - 
CPU#3 stuck for 11s! [nfsd:20541]
/var/log/messages:Jul 23 03:39:41 server111 kernel: BUG: soft lockup - 
CPU#5 stuck for 10s! [nfsd:20540]
/var/log/messages:Jul 23 03:42:21 server111 kernel: BUG: soft lockup - 
CPU#3 stuck for 10s! [nfsd:20549]
/var/log/messages:Jul 23 03:42:51 server111 kernel: BUG: soft lockup - 
CPU#1 stuck for 17s! [nfsd:20542]
/var/log/messages:Jul 23 03:43:07 server111 kernel: BUG: soft lockup - 
CPU#3 stuck for 15s! [nfsd:20553]
/var/log/messages:Jul 23 03:47:49 server111 kernel: BUG: soft lockup - 
CPU#7 stuck for 16s! [nfsd:20545]
/var/log/messages:Jul 23 03:48:22 server111 kernel: BUG: soft lockup - 
CPU#1 stuck for 23s! [nfsd:20547]
