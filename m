Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from jarvis.server1.odu.edu ([128.82.96.116]:34130 "EHLO
	jarvis.server1.odu.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757804Ab0EXVSn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 17:18:43 -0400
From: "Kumar, Amit H." <AHKumar@odu.edu>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "owner-linux-nfs@vger.kernel.org" <owner-linux-nfs@vger.kernel.org>
Date: Mon, 24 May 2010 17:18:41 -0400
Subject: FW: Yet Another NFS Performance Question
Message-ID: <A17A76CF549D0F4EBC38AD7AA7A3CBDA7675EA69FD@MUFASA.ts.odu.edu>
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi All:

Context: NFSv3:

I would like to get your input on the following NFS stats recorded on our server. I have read up this thread(http://www.opensubscriber.com/message/nfs@lists.sourceforge.net/7833588.html) describing the contents of /proc/net/rpc/nfsd;

My Numbers are really high, for 'th' line in nfsd file: I am not able to ascertain as to:  My server is heavily busy or poorly performing, because each thread is busy that big number of times on the 'th' line; 

Q0. Does the stats below represent a bad performance?
Q1. Is there anymore way I can tweak this if this represents a bad performance? 

You input is greatly appreciated and will help us tweak this server and better understand the performance. 

Thank you,
Amit


/******************/
Generally on all of My Client this is what the nfsstats reports: retans number fluctuates but not greatly. To me retrans number seems negligible. 
# nfsstat
Client rpc stats:
calls      retrans    authrefrsh
138601858   13119      0

# uname -a
Linux nfs3-io-0-3.local 2.6.18-53.1.14.el5 #1 SMP Wed Mar 5 11:37:38 EST 2008 x86_64 x86_64 x86_64 GNU/Linux

NFS server:# cat /proc/net/rpc/nfsd
rc 579356 2561581103 930328921
fh 68593119 0 0 0 0
io 3005241904 1001209956
th 128 43577408 757955.761 677495.276 387088.572 462962.421 425292.746 165116.697 66147.746 26071.602 8148.127 9079.092
ra 256 319824137 968005 35905 6510 2981 1790 1450 1056 895 634 141481
net 3493483810 0 3492990059 29031
rpc 3489730527 0 0 0 0
proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 116 11578551 9138195 364276603 91767377 380 318502944 2552319828 174234 11301 1470 0 178776 6302 15842 2962 1001562 335879 122371298 117 0 18968257
proc4 2 0 0
proc4ops 40 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

NFS server:# nfsstat
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
-803696698   0          0          0          0

Server nfs v3:
null         getattr      setattr      lookup       access       readlink
116       0% 11579177  0% 9138217   0% 364330037 10% 91788465  2% 380       0%
read         write        create       mkdir        symlink      mknod
319793180  9% -1742476768 73% 174245    0% 11301     0% 1470      0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
178780    0% 6302      0% 15842     0% 2962      0% 1001733   0% 335887    0%
fsstat       fsinfo       pathconf     commit
122372898  3% 117       0% 0         0% 18968795  0%

NFS server:# ifconfig -i eth0
eth0      Link encap:Ethernet  HWaddr xx:xx:xx:70:AD:27
          inet addr:xx.xx.24.251  Bcast:xxx.xx.24.255  Mask:255.255.255.0
          inet6 addr: xxxx::xxx:9ff:fe70:ad27/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:180118110167 errors:0 dropped:4 overruns:0 frame:0
          TX packets:238857904405 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:74126472507659 (67.4 TiB)  TX bytes:306386976112971 (278.6 TiB)
          Interrupt:169 Memory:f8000000-f8012100

/******************/
