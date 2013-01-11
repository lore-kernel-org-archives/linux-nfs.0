Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36765 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab3AKTT5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jan 2013 14:19:57 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Samuel Li <samuel.li@isilon.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nlm svid changes from pid --> nlm_lockowner
Date: Fri, 11 Jan 2013 19:19:54 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91199BC94@SACEXCMBX04-PRD.hq.netapp.com>
References: <50F05FFE.1020901@isilon.com>
In-Reply-To: <50F05FFE.1020901@isilon.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-01-11 at 13:54 -0500, Samuel Li wrote:
+AD4- A simple question with NLM svid implementation with after 2.6.16 or later.
+AD4- 
+AD4- In the old days when linux client request and NLM lock it submits a
+AD4- svid with the content of the client pid. However this appears to have
+AD4- changed a few year ago and I get an incremental number starting from 0.
+AD4- 
+AD4- from the NLM server side we only report the content of svid. I am trying 
+AD4- to find a way to identify the end user application request.
+AD4- 
+AD4- for example
+AD4- 
+AD4- +AFs-sli+AEA-fed16-vm nfs3+AF0AIw- ./gwaiting +ACY- ./gwaiting +ACY- ./gwaiting +ACY-  (excl lock 
+AD4- programs)
+AD4- +AFs-2+AF0- 977  +ADw---pid
+AD4- +AFs-3+AF0- 978
+AD4- +AFs-4+AF0- 979
+AD4- 
+AD4-     tshark -i eth0 -R +ACI-nlm+ACI- -V +AHw- grep -i svid
+AD4- OOPS: dissector table +ACI-sctp.ppi+ACI- doesn't exist
+AD4- Protocol being registered is +ACI-Datagram Transport Layer Security+ACI-
+AD4- Running as user +ACI-root+ACI- and group +ACI-root+ACI-. This could be dangerous.
+AD4- Capturing on eth0
+AD4-            svid: 4
+AD4-            svid: 3
+AD4-            svid: 5
+AD4-            svid: 3
+AD4-            svid: 4
+AD4-            svid: 4
+AD4-            svid: 4
+AD4-            svid: 5
+AD4-            svid: 5
+AD4- 
+AD4- How do I determine from the client side who owns these NLM processes?
+AD4- 
+AD4- The file lock in question was
+AD4- inode 4318756868 so I could determine the lock.
+AD4- 
+AD4- cat /proc/locks
+AD4- 1: POSIX  ADVISORY  WRITE 979 00:2a:4315692708 0 EOF
+AD4- 1: -+AD4- ACCESS ADVISORY  WRITE 978 00:2a:4315692708 0 EOF
+AD4- 2: POSIX  ADVISORY  WRITE 1778 00:10:16424 0 EOF
+AD4- 3: POSIX  ADVISORY  WRITE 1677 00:10:18376 0 EOF
+AD4- 
+AD4- Now assume I did not have the output of /proc/locks and only 
+AD4- nlm+AF8-lockowner number how would I debug this?

The POSIX lock inheritance rules under the clone() system call (where
POSIX locks must follow the file descriptor table and +AF8-not+AF8- the pid
inheritance rules) mean that the svid does not map naturally into a pid.
So post-2.6.16 we no longer try to pretend that is the case.

The bottom line is that you can use the svid as a debugging tool for
figuring out which locks belong to the same lock owner, but you cannot
map it to a pid.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
