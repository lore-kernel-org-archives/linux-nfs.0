Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:16724 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381Ab3KVTez convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Nov 2013 14:34:55 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id rAMJYsw3004594
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 22 Nov 2013 19:34:55 GMT
Received: from aserz7021.oracle.com (aserz7021.oracle.com [141.146.126.230])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id rAMJYrVU023308
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 22 Nov 2013 19:34:54 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id rAMJYrUd023302
	for <linux-nfs@vger.kernel.org>; Fri, 22 Nov 2013 19:34:53 GMT
MIME-Version: 1.0
Message-ID: <931f1e06-eca3-4f12-ad8a-99a93442409a@default>
Date: Fri, 22 Nov 2013 11:34:04 -0800 (PST)
From: Tim Rafert <tim.rafert@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: ACL and NFSv4 expectations
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looking for assistance if the following are REAL issues or expected behavior using NFSv4 ACL (on linux ol6 and interoperating with solaris).  Thanks in advance.

1) Is there a max # of entries that can be stored in an ACL?  If so - what is it (or is dependent on the device)?

2) Is it up to my own implementation instead of the "NFS Client" on the OS to try and keep the ACLs clean/organized/etc?  See my next question for further clarification

3) If a user adds the same ACE into an ACL multiple times - then it is actually added multiple times?  For example:
 
bash-4.1$ nfs4_setfacl -aA:fd:OWNER@:rwaDdxtTnNCo,A:fdi:EVERYONE@:rxtncy,D::EVERYONE@:DT,A::user1@xyz.com:rwaxtc exampleDir
bash-4.1$ nfs4_getfacl exampleDir
A:fd:OWNER@:rwaDdxtTnNCo
A:fdi:EVERYONE@:rxtncy
D::EVERYONE@:DT
A::user1@xyz.com:rwaxtc
A:fdig:GROUP@:rxtncy
A:fdi:EVERYONE@:rxtncy
A::OWNER@:rwaDxtTnNcCoy
A:g:GROUP@:rxtncy
A::EVERYONE@:rxtncy
bash-4.1$ nfs4_setfacl -aA:fd:OWNER@:rwaDdxtTnNCo,A:fdi:EVERYONE@:rxtncy,D::EVERYONE@:DT,A::user1@xyz.com:rwaxtc exampleDir
bash-4.1$ nfs4_getfacl exampleDir
A:fd:OWNER@:rwaDdxtTnNCo
A:fdi:EVERYONE@:rxtncy
D::EVERYONE@:DT
A::user1@xyz.com:rwaxtc
A:fd:OWNER@:rwaDdxtTnNCo
A:fdi:EVERYONE@:rxtncy
D::EVERYONE@:DT
A::user1@xyz.com:rwaxtc
A:fdig:GROUP@:rxtncy
A:fdi:EVERYONE@:rxtncy
A::OWNER@:rwaDxtTnNcCoy
A:g:GROUP@:rxtncy
A::EVERYONE@:rxtncy

4) ACL "caching" - it appears that if from one client-host - a user alters the ACL and then from another client-host - a user also alters the ACL - then one of the alterations can be lost (if they are within a minute or some cache timeframe).  For example:
 
>From a Linux host:
bash-4.1$ mkdir nfscache
bash-4.1$
bash-4.1$
bash-4.1$ nfs4_getfacl nfscache
A:fdig:GROUP@:rxtncy
A:fdi:EVERYONE@:rxtncy
A::OWNER@:rwaDxtTnNcCoy
A:g:GROUP@:rxtncy
A::EVERYONE@:rxtncy
bash-4.1$ nfs4_setfacl -a A::user1@xyz.com:rwaxtc nfscache
bash-4.1$ nfs4_getfacl nfscache
A::user1@xyz.com:rwaxtc
A:fdig:GROUP@:rxtncy
A:fdi:EVERYONE@:rxtncy
A::OWNER@:rwaDxtTnNcCoy
A:g:GROUP@:rxtncy
A::EVERYONE@:rxtncy
 
Then from Solaris host (we see "user1" was correctly added - but then we add another user: "user2"):
bash-4.1$ ls -aldV nfscache/
drwxr-xr-x+  2 trafert  pditdba        2 Oct 30 19:26 nfscache/
            user:user1:rwxp--a---c---:-------:allow
                 group@:r-x---a-R-c--s:fdi----:allow
              everyone@:r-x---a-R-c--s:fdi----:allow
                 owner@:rwxp-DaARWcCos:-------:allow
                 group@:r-x---a-R-c--s:-------:allow
              everyone@:r-x---a-R-c--s:-------:allow
bash-4.1$ chmod A+user:user2:rwxp--a---c---::allow nfscache
bash-4.1$ ls -aldV nfscache/
drwxr-xr-x+  2 trafert  pditdba        2 Oct 30 19:26 nfscache/
             user:user2:rwxp--a---c---:-------:allow
             user:user1:rwxp--a---c---:-------:allow
                 group@:r-x---a-R-c--s:fdi----:allow
              everyone@:r-x---a-R-c--s:fdi----:allow
                 owner@:rwxp-DaARWcCos:-------:allow
                 group@:r-x---a-R-c--s:-------:allow
              everyone@:r-x---a-R-c--s:-------:allow
 
 
Then come back to the Linux host (we only see the original setting where "user1" was added - "user2" is missing).  Then we add another user "user3".  At which point the "user2" addition is completely lost on either hosts:
 
bash-4.1$ nfs4_getfacl nfscache
A::user1@xyz.com:rwaxtc
A:fdig:GROUP@:rxtncy
A:fdi:EVERYONE@:rxtncy
A::OWNER@:rwaDxtTnNcCoy
A:g:GROUP@:rxtncy
A::EVERYONE@:rxtncy
bash-4.1$ nfs4_setfacl -a A::user3@xyz.com:rwaxtc nfscache
bash-4.1$ nfs4_getfacl nfscache
A::user3@xyz.com:rwaxtc
A::user1@xyz.com:rwaxtc
A:fdig:GROUP@:rxtncy
A:fdi:EVERYONE@:rxtncy
A::OWNER@:rwaDxtTnNcCoy
A:g:GROUP@:rxtncy
A::EVERYONE@:rxtncy
 
Back on Solaris - "user2" is also lost:
bash-4.1$ ls -aldV nfscache/
drwxr-xr-x+  2 trafert  pditdba        2 Oct 30 19:28 nfscache/
             user:user3:rwxp--a---c---:-------:allow
             user:user1:rwxp--a---c---:-------:allow
                 group@:r-x---a-R-c--s:fdi----:allow
              everyone@:r-x---a-R-c--s:fdi----:allow
                 owner@:rwxp-DaARWcCos:-------:allow
                 group@:r-x---a-R-c--s:-------:allow
              everyone@:r-x---a-R-c--s:-------:allow
