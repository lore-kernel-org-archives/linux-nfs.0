From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: how to execute a script from NFS mount (which disconnected)?
Date: Tue, 22 May 2007 12:37:33 +0200
Message-ID: <4652C7ED.9010309@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqRkK-00060X-SQ
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 03:37:40 -0700
Received: from mail.syneticon.net ([213.239.212.131] helo=mail2.syneticon.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqRkL-0008At-8g
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 03:37:43 -0700
Received: from postfix1.syneticon.net (postfix1.syneticon.net [192.168.112.6])
	by mail2.syneticon.net (Postfix) with ESMTP id 42A9F5D526
	for <nfs@lists.sourceforge.net>; Tue, 22 May 2007 12:37:37 +0200 (CEST)
Received: from localhost (filter1.syneticon.net [192.168.113.3])
	by postfix1.syneticon.net (Postfix) with ESMTP id DA34295CE
	for <nfs@lists.sourceforge.net>; Tue, 22 May 2007 12:37:36 +0200 (CEST)
Received: from postfix1.syneticon.net ([192.168.113.4])
	by localhost (mx03.syneticon.net [192.168.113.3]) (amavisd-new,
	port 10025)
	with ESMTP id sVe0rEVKC9rG for <nfs@lists.sourceforge.net>;
	Tue, 22 May 2007 10:37:34 +0000 (UTC)
Received: from [192.168.10.145] (unknown [87.79.98.133])
	by postfix1.syneticon.net (Postfix) with ESMTP
	for <nfs@lists.sourceforge.net>; Tue, 22 May 2007 12:37:34 +0200 (CEST)
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

This question may sound silly, but I didn't find a proper solution to it.

I have a script on a NFS share. The purpose of this script is to do some 
network reconfiguration for Xen.

Unfortunately, it fails to execute somewhere in the middle.

Basically, the script brings the network interface down, does a bit of 
reconfiguring, and then, the interface is brought up.


In a short form, the script looks like that:

#!/bin/bash

echo Start

ifdown bond0

echo Step 1...
sleep 4s

echo Step 2...
sleep 4s

echo Step 3...
sleep 4s

echo Step 4...
sleep 4s

echo Step 5...
sleep 4s

ifup bond0

echo End



Unfortunately, when I execute it locally, the script freezes somewhere 
about step 2 or 3. Which I could perfectly understand - as the system 
can't read it.
But I did a "cat script" just before running it - so the system should 
have it cached, right?
Sometimes only, the script executes fully.


How can I execute a script from NSF mount - a script which reconfigures 
a network interface, and there is a period of network disconnection?


-- 
Tomasz Chmielewski
http://wpkg.org

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
