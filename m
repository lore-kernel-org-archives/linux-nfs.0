From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: rpc.mountd stops functioning
Date: Thu, 05 Aug 2004 12:19:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <411217BE.8070209@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsgIE-0000SJ-Ax
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 04:20:18 -0700
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1BsgID-0002zp-MM
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 04:20:18 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail.admin.local (Postfix) with ESMTP id 5EA8697E42D
	for <nfs@lists.sourceforge.net>; Thu,  5 Aug 2004 12:19:28 +0100 (BST)
Received: from framestore-cfc.com (sys33.prod.local [172.18.10.33])
	by mail.admin.local (Postfix) with ESMTP id 63DC0506BAC
	for <nfs@lists.sourceforge.net>; Thu,  5 Aug 2004 12:19:26 +0100 (BST)
To: nfs@lists.sourceforge.net
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

Hello,

For a long time we've been experiencing problems with rpc.mountd 
stopping functioning.

I'm finding it hard to pinpoint the precise circumstances where we 
encounter a problem, but here is what we have observed:

- A mount request, or a showmount -e, to the server will hang

- The server will print a log message authenticating the mount request

- The server doesn't print log messages that it has authenticated 
unmount requests.

- Killing rpc.mountd and then restarting it fixes the problem (I've not 
tried a HUP)

- There is a correlation between the number of mounts being handled 
(i.e. the number of entries in rmtab) and the frequency of the problem.

- The problem only occurs on servers that are mounted by a significant 
number of hosts (500-700).

- The more exports on the server, the more frequently the problem occurs.

- It should be noted that clients are mounting subdirectories of a 
single exported filesystem, so number of rmtab entries > number of xtab 
entries.

- Clearing the rmtab and restarting nfs (service nfs restart) seems to 
provide the longest time between failures.

-- 
Johan van den Dorpe


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
