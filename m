Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hop-nat-141.emc.com ([168.159.213.141]:29395 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753377Ab3AKSzG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jan 2013 13:55:06 -0500
Received: from hop04-l1d11-si03.isus.emc.com (HOP04-L1D11-SI03.isus.emc.com [10.254.111.23])
	by mexforward.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id r0BIt3vJ029213
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jan 2013 13:55:04 -0500
Received: from mailhub.lss.emc.com (mailhubhoprd01.lss.emc.com [10.254.221.251]) by hop04-l1d11-si03.isus.emc.com (RSA Interceptor) for <linux-nfs@vger.kernel.org>; Fri, 11 Jan 2013 13:54:57 -0500
Received: from seacasht01.desktop.isilon.com (seacasht01.isilon.com [137.69.159.79])
	by mailhub.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id r0BIsrTw027791
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jan 2013 13:54:55 -0500
Message-ID: <50F05FFE.1020901@isilon.com>
Date: Fri, 11 Jan 2013 13:54:54 -0500
From: Samuel Li <samuel.li@isilon.com>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
Subject: nlm svid changes from pid --> nlm_lockowner
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


A simple question with NLM svid implementation with after 2.6.16 or later.

In the old days when linux client request and NLM lock it submits a
svid with the content of the client pid. However this appears to have
changed a few year ago and I get an incremental number starting from 0.

from the NLM server side we only report the content of svid. I am trying 
to find a way to identify the end user application request.

for example

[sli@fed16-vm nfs3]# ./gwaiting & ./gwaiting & ./gwaiting &  (excl lock 
programs)
[2] 977  <--pid
[3] 978
[4] 979

    tshark -i eth0 -R "nlm" -V | grep -i svid
OOPS: dissector table "sctp.ppi" doesn't exist
Protocol being registered is "Datagram Transport Layer Security"
Running as user "root" and group "root". This could be dangerous.
Capturing on eth0
           svid: 4
           svid: 3
           svid: 5
           svid: 3
           svid: 4
           svid: 4
           svid: 4
           svid: 5
           svid: 5

How do I determine from the client side who owns these NLM processes?

The file lock in question was
inode 4318756868 so I could determine the lock.

cat /proc/locks
1: POSIX  ADVISORY  WRITE 979 00:2a:4315692708 0 EOF
1: -> ACCESS ADVISORY  WRITE 978 00:2a:4315692708 0 EOF
2: POSIX  ADVISORY  WRITE 1778 00:10:16424 0 EOF
3: POSIX  ADVISORY  WRITE 1677 00:10:18376 0 EOF

Now assume I did not have the output of /proc/locks and only 
nlm_lockowner number how would I debug this?

I found the change in

commit 7bab377fcb495ee2e5a1cd69d235f8d84c76e3af
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Mar 20 13:44:06 2006 -0500

      lockd: Don't expose the process pid to the NLM server

      Instead we use the nlm_lockowner->pid.

      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>





-- 
Best regards,

Samuel Li
Escalation Engineer
EMC²| Isilon Storage Division
samuel.li@isilon.com

