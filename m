From: Jeff Blaine <jblaine@mitre.org>
Subject: 2.4.21 NFSv3 performance graph
Date: Fri, 14 Jan 2005 14:00:03 -0500
Message-ID: <41E816B3.4030702@mitre.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpWg8-0005E4-Sw
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 11:00:12 -0800
Received: from smtpproxy2.mitre.org ([192.160.51.65] helo=smtp-bedford-dr.mitre.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CpWg3-00079N-1u
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 11:00:09 -0800
Received: from smtp-bedford-dr.mitre.org (localhost.localdomain [127.0.0.1])
	by smtp-bedford-dr.mitre.org (8.11.6/8.11.6) with SMTP id j0EJ05C32505
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 14:00:05 -0500
Received: from smtp-bedford-dr.mitre.org (localhost.localdomain [127.0.0.1])
	by smtp-bedford-dr.mitre.org (Postfix) with ESMTP id 2AD954F8D8
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 14:00:05 -0500 (EST)
Received: from linus.mitre.org (rcf-smtp.mitre.org [129.83.10.1])
	by smtp-bedford-dr.mitre.org (8.11.6/8.11.6) with ESMTP id j0EJ05e32484
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 14:00:05 -0500
Received: from [127.0.0.1] (unity-17-50.mitre.org [129.83.17.50])
	by linus.mitre.org (8.12.10/8.12.10) with ESMTP id j0EJ034o020083
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 14:00:04 -0500 (EST)
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

Can anyone tell me what is happening in the graph at the URL
below?  I can replicate it on any Linux box running 2.4.21
and changing rsize/wsize doesn't affect it at all.  This
was captured from a 2.6GHz P4 client machine.  Same thing
is visible with a Dual 3GHz Xeon box with 4GB memory as a
client.  A Solaris 9 client does not display this "falling
on face" behavior.

http://www.kickflop.net/temp/sol9-server-linux2421-client-gigE-ag930m_10533_image001.gif

-- 
If it ain't broke, don't fix it.
If it ain't needed, don't adopt it.



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
