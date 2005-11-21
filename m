From: Chris Dos <chris@chrisdos.com>
Subject: export very large filesystem
Date: Mon, 21 Nov 2005 07:46:18 -0700
Message-ID: <4381DDBA.9090509@chrisdos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EeCwO-000800-0V
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 06:46:44 -0800
Received: from windwalker.openinnovations.com
	([71.33.251.73] helo=windwalker.chrisdos.com ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EeCwH-0005IH-PY
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 06:46:41 -0800
Received: from localhost (localhost.localdomain [127.0.0.1])
	by windwalker.chrisdos.com (Postfix) with ESMTP id C570F15475B
	for <nfs@lists.sourceforge.net>; Mon, 21 Nov 2005 07:46:22 -0700 (MST)
Received: from windwalker.chrisdos.com ([127.0.0.1])
	by localhost (windwalker.chrisdos.com [127.0.0.1]) (amavisd-new, port 10024)
	with SMTP id 06327-05 for <nfs@lists.sourceforge.net>;
	Mon, 21 Nov 2005 07:46:07 -0700 (MST)
Received: from [10.240.48.67] (unknown [164.47.8.113])
	by windwalker.chrisdos.com (Postfix) with ESMTP id AAC141559B8
	for <nfs@lists.sourceforge.net>; Mon, 21 Nov 2005 07:46:07 -0700 (MST)
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

I have a customer that would like to export their 22.5 TB XFS file system via 
NFS using Linux 2.6.14.  Before I even attempt to do this, can NFS v2/3/4 even 
handle something like this?

-- 
--
Chris Dos


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
