From: Terry Spaulding <spauld@us.ibm.com>
Subject: statd (status) port used when setting specific port for lockd
 - SLES9 SP3 Linux for System z.
Date: Thu, 30 Aug 2007 07:47:39 -0400
Message-ID: <OFDE88F129.B785EDAA-ON85257347.0040488E-85257347.0040C993@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQiVz-0006Ou-Ih
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 04:48:47 -0700
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQiW2-0007Vi-M9
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 04:48:52 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7UBlBg9018158
	for <nfs@lists.sourceforge.net>; Thu, 30 Aug 2007 07:47:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id
	l7UBlBbB106268
	for <nfs@lists.sourceforge.net>; Thu, 30 Aug 2007 07:47:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l7UBlBfF011105
	for <nfs@lists.sourceforge.net>; Thu, 30 Aug 2007 07:47:11 -0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


I noticed that when I set the lockd ports to specific port that the statd
port is set to the same port.

Should I also set statd to a specific unique port  different from lockd ?

Is there any problem with statd using the same port as lockd ?

Any assistance is greatly appreciated.


My current NFS Server and client:

linux01:/ # rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100005    2   udp   2050  mountd
    100005    2   tcp   2050  mountd
    100005    3   udp   2050  mountd
    100005    3   tcp   2050  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100024    1   udp   2051  status
    100021    1   udp   2051  nlockmgr
    100021    3   udp   2051  nlockmgr
    100021    4   udp   2051  nlockmgr
    100024    1   tcp   2051  status
    100021    1   tcp   2051  nlockmgr
    100021    3   tcp   2051  nlockmgr
    100021    4   tcp   2051  nlockmgr
    100005    1   udp   2050  mountd
linux01:/ #

NFS Client:
linux02:~ # rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   2051  status
    100021    1   udp   2051  nlockmgr
    100021    3   udp   2051  nlockmgr
    100021    4   udp   2051  nlockmgr
    100024    1   tcp   2051  status
    100021    1   tcp   2051  nlockmgr
    100021    3   tcp   2051  nlockmgr
    100021    4   tcp   2051  nlockmgr
linux02:~ #

Thanks ...............


Regards,
Terry L. Spaulding
spauld@us.ibm.com


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
