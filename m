From: Greg Whynott <greg@dkp.com>
Subject: render farm NFS server is having hard time staying up.
Date: Tue, 19 Oct 2004 11:35:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41753444.9030300@dkp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CJw1t-0001FR-Ub
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 08:36:05 -0700
Received: from mail.dkp.com
	([204.191.16.3] helo=postman.dkp.com ident=hidden-user)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CJw1s-0001aq-Vn
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 08:36:05 -0700
Received: from localhost (unknown [127.0.0.1])
	by postman.dkp.com (Postfix) with ESMTP id 423651CE350
	for <nfs@lists.sourceforge.net>; Tue, 19 Oct 2004 15:35:57 +0000 (UTC)
Received: from postman.dkp.com ([127.0.0.1])
 by localhost (postman [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 02665-02 for <nfs@lists.sourceforge.net>;
 Tue, 19 Oct 2004 11:35:55 -0400 (EDT)
Received: from [10.0.0.213] (mac-shake2.dkp.com [10.0.0.213])
	by postman.dkp.com (Postfix) with ESMTP
	for <nfs@lists.sourceforge.net>; Tue, 19 Oct 2004 11:35:55 -0400 (EDT)
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello Folks,

    I'm looking for any information which may help me resolve a NFS 
server issues we are seeing.  We are seeing about 1-3% curruption on 
files wrote to the array over NFS when under load.  Some times we'll see 
I/O errors, other times we'll see this error in the dmesg output"nfs: 
server murdock not responding, timed out",  and othertimes the result is 
a bad file. 

here are the details of the enviroment:

@200-300 dual cpu render nodes (depending on time of day).
all connected to gigabit network ports.

NFS server is a dual 2.8 p4 with 4gigs memory.

auto neg is off on switch ports,  locked to 1000/full-dup/flow-control

render nodes mount the file server(s) with automount using these options:
-rw,insecure,hard,rsize=8192,wsize=8192,intr,timeo=600

RedHat 9 is running on the servers:
2.4.20-8 with big mem support.
rw,no_root_squash,insecure,sync,no_subtree_check
24 nfsd's fire off at startup.

contents of proc-nfsd:
[root@barney root]# cat /proc/net/rpc/nfsd
rc 6738 70516059 9738836
fh 500 79366229 10104583 667218 0
io 196640402 2028579561
th 24 387656 14064.970 2016.480 615.180 93.980 239.450 152.980 143.640 
144.910 2.240 831.600
ra 48 47883 0 0 0 0 74 0 0 0 0 121
net 80270754 80270754 0 0
rpc 80261633 9121 0 9121 0
proc2 18 22 6763 918 0 1406 1 0 0 163637 142 0 0 0 0 1 0 0 11
proc3 22 4 2462879 570357 1141041 5515254 650 48078 69567752 142094 6308 
3 0 3 0 71582 0 6417 0 4474 4477 0 547359


RedHat 7.3 is running on the render nodes:
2.4.18-.7
export options:

The disk arrays connected to the server are Sun T4s in a 6320 array via 
dual 2G FC (active/active),  6 trays of 14 disks, hardware RAID 5 horz,  
RAID 0 vert.  The switches report few errors (counters reset 7 days ago):

  Port name is BARNEY
  MTU 1518 bytes, encapsulation ethernet
  300 second input rate: 23597672 bits/sec, 2266 packets/sec, 2.39% 
utilization
  300 second output rate: 7404080 bits/sec, 2025 packets/sec, 0.76% 
utilization
  595831889 packets input, 589820579851 bytes, 0 no buffer
  Received 63119 broadcasts, 0 multicasts, 595768764 unicasts
  9 input errors, 6 CRC, 0 frame, 0 ignored
  3 runts, 0 giants, DMA received 595831869 packets
  765643165 packets output, 620030207291 bytes, 0 underruns
  Transmitted 57746415 broadcasts, 551424 multicasts, 707345326 unicasts
  0 output errors, 0 collisions, DMA transmitted 765643165 packets



I have added this as part of the system startup:
echo 262144 > /proc/sys/net/core/rmem_default
echo 262144 > /proc/sys/net/core/rmem_max
/etc/init.d/nfs start
echo 65536 > /proc/sys/net/core/rmem_default
echo 65536 > /proc/sys/net/core/rmem_max


This is a render farm where images are rendered then wrote out the the 
array when complete.  At the same time there is are people reading files 
from the same array.  I suspect we are giving our NFS server a DoS of 
sorts,  my hopes are we can set things up in such away that if a file 
starts to write to the array, it'll finish and not write out bogas 
data.  If the server is to busy it should reject further connections 
rather than handle them incorrectly. pipe dream?

thanks very much for your time,  if you wish further info please let me 
know, I must run off to a meeting,

greg










-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
