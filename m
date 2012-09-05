Return-Path: linux-nfs-owner@vger.kernel.org
Received: from odin2.bull.net ([129.184.85.11]:43165 "EHLO odin2.bull.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981Ab2IENDn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 09:03:43 -0400
Received: from MSGC-003.bull.fr (MSGC-003.frcl.bull.fr [129.184.87.131])
	by odin2.bull.net (Bull S.A.) with ESMTP id 1907118144
	for <linux-nfs@vger.kernel.org>; Wed,  5 Sep 2012 14:39:46 +0200 (CEST)
Message-ID: <50474858.1020801@bull.net>
Date: Wed, 05 Sep 2012 14:40:56 +0200
From: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFSv3 caching vs NFSv4
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello everyone,

Performing some attribute caching tests I think I found some 
inconsistencies between nfsv3 and nfsv4. Running a kernel based on 
rhel6.3 (2.6.32-279.el6.x86_64) I found nfsv4 doesn't manage a file 
modified on the server side (even with the noac mount option) while 
nfsv3 does.

My test will be modifying a file every second on the server mount point:

[root@nfs ~]#  FILE=/tmp/nfs_server/myfile ;  while true ; do sleep 1 ; 
sed -i 's/text1/text2/g' $FILE ; cat $FILE ; sleep 1; sed -i 
's/text2/text1/g' $FILE ; cat $FILE ; done
text2
text1
text2
text1
text2
(and so on...)

Meanwhile, the client (which BTW is the same machine) will read the file 
every second :

With NFSv4:

[root@nfs ~]# mount -o noac,vers=4 nfs:/tmp/nfs_server/ /tmp/nfs_client/
[root@nfs ~]# for i in 1 2 3 4 5 ; do cat /tmp/nfs_client/myfile; sleep 
1 ; done
text2
text1
text1
text1
text1

With NFSv3:
[root@nfs ~]# mount -o noac,vers=3 nfs:/tmp/nfs_server/ /tmp/nfs_client/
[root@nfs ~]# for i in 1 2 3 4 5 ; do cat /tmp/nfs_client/myfile; sleep 
1 ; done
text1
text2
text1
text2
text1

I can see in the tcpdump traces how the new change attribute and the 
FATTR4_TIME_MODIFY attributes are well received but it's as if the nfs 
client were ignoring these changes. I've been searching in the NFS list 
but I didn't find anything similar. Is this a bug or just a normal 
behavior? Sorry if it has been already pointed out.

Regards,

Diego Moreno
