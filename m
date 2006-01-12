From: David Dougall <davidd@et.byu.edu>
Subject: nfs client weirdness
Date: Thu, 12 Jan 2006 10:27:23 -0700 (MST)
Message-ID: <Pine.LNX.4.58.0601121016220.7720@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ex6EW-0008DA-Pp
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 09:27:32 -0800
Received: from postal1.et.byu.edu ([128.187.48.11])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ex6EV-0000dw-4B
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 09:27:32 -0800
Received: from localhost (localhost [127.0.0.1])
	by postal1.et.byu.edu (Postfix) with ESMTP id 489AB4E12
	for <nfs@lists.sourceforge.net>; Thu, 12 Jan 2006 10:27:24 -0700 (MST)
Received: from postal1.et.byu.edu ([127.0.0.1])
	by localhost (postal1.et.byu.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 24390-03 for <nfs@lists.sourceforge.net>;
	Thu, 12 Jan 2006 10:27:23 -0700 (MST)
Received: from lewis.et.byu.edu (lewis.et.byu.edu [10.5.113.201])
	by postal1.et.byu.edu (Postfix) with ESMTP id E74E84E10
	for <nfs@lists.sourceforge.net>; Thu, 12 Jan 2006 10:27:23 -0700 (MST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

I have a cluster of machines that mount nfs shares and reexport them
through samba.  This has been working fairly cleanly for several years.  I
made a change recently to newer hardware and what I think was a small
kernel change...
Anyway, the symptoms that are exhibited are samba drives not mapping, slow
access, etc.  I log into the samba servers(which are nfs clients) and
everything looks fine as far as load and nfs mounting "appears" OK from a
cursory look.  However my `dmesg` and syslog are full of lockd and
other bad-looking errors:
lockd: unexpected unlock status: 7
lockd: unexpected unlock status: 1
VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice
day...
lockd: can't encode arguments: 5


These nfs clients are running 2.6.13 kernel on Intel Xeon 64 machines:
>cat /proc/version
Linux version 2.6.13 (root@ct355l15.et.byu.edu) (gcc version 3.3.5 (Debian
1:3.3.5-13)) #1 SMP Tue Sep 13 15:49:24 MDT 2005
The network card is an e1000 driver.  Samba is version 3.0.14a.

The nfs servers are mostly 2.4.26 kernel running 32 bit kernels.  2 nfs
servers have been upgraded to SLES9 with 2.6.5-7.191.  I am not sure if
the heterogeneous server environment may cause a problem for the clients.
Those 2 nfs servers were upgraded a few weeks ago.

The gist of the question is:
Are these error messages bad?  If so, is there a kernel upgrade I should
do on either the client or server to prevent them(client would be much
easier)?  What other diagnostic information can I give?
Thanks
--David Dougall


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
