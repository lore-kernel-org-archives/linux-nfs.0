From: Jeff Blaine <jblaine@mitre.org>
Subject: NFS file xfer of size of client memory = bad scene
Date: Fri, 14 Jan 2005 18:34:22 -0500
Message-ID: <41E856FE.6080706@mitre.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpaxW-0008Jo-M5
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 15:34:26 -0800
Received: from smtp-bedford-dr-x.mitre.org ([192.160.51.65] helo=smtp-bedford-dr.mitre.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CpaxW-00058E-6F
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 15:34:26 -0800
Received: from smtp-bedford-dr.mitre.org (localhost.localdomain [127.0.0.1])
	by smtp-bedford-dr.mitre.org (8.11.6/8.11.6) with SMTP id j0ENYOE25697
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 18:34:24 -0500
Received: from smtp-bedford-dr.mitre.org (localhost.localdomain [127.0.0.1])
	by smtp-bedford-dr.mitre.org (Postfix) with ESMTP id 74ABB4F8D8
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 18:34:24 -0500 (EST)
Received: from linus.mitre.org (linus.mitre.org [129.83.10.1])
	by smtp-bedford-dr.mitre.org (8.11.6/8.11.6) with ESMTP id j0ENYOM25673
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 18:34:24 -0500
Received: from [127.0.0.1] (unity-17-50.mitre.org [129.83.17.50])
	by linus.mitre.org (8.12.10/8.12.10) with ESMTP id j0ENYN4o019761
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 18:34:24 -0500 (EST)
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

I have a box with 4GB.  It's running 2.6.10.

I am trying to run Iozone with -g and an argument to it
that is larger than the physical memory in the NFSv3
client machine.

For instance, on this 4GB box, I am trying '-g 4224m'.
More specifically, the entire command line is:

     ./iozone -a -g 4224m -f /sol9box/testfile

As soon as it finally gets to trying a file size of
4194304, oom-killer steps in and starts blasting
processes off my machine (WTF?  Great.)

Brings up 'oom-killer' instances under 2.6.10 and the
whole benchmark run dies, sometimes along with my
shell, my X session, ANY net services at all (can't
SSH into the box... can't get console to wake up...),
etc.

Exact same command line worked in Linux 2.4.21 loaded
on this same exact machine with the same NFSv3 server
being talked to.



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
