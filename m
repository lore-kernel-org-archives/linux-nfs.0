From: Jeff Blaine <jblaine@mitre.org>
Subject: General NFSv3 + Linux kernel timeline?
Date: Tue, 11 Jan 2005 11:32:33 -0500
Message-ID: <41E3FFA1.8020609@mitre.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CoOwh-0006ac-4h
	for nfs@lists.sourceforge.net; Tue, 11 Jan 2005 08:32:39 -0800
Received: from smtp-bedford-dr-x.mitre.org ([192.160.51.65] helo=smtp-bedford-dr.mitre.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CoOwf-0007Ii-1j
	for nfs@lists.sourceforge.net; Tue, 11 Jan 2005 08:32:38 -0800
Received: from smtp-bedford-dr.mitre.org (localhost.localdomain [127.0.0.1])
	by smtp-bedford-dr.mitre.org (8.11.6/8.11.6) with SMTP id j0BGWZ126654
	for <nfs@lists.sourceforge.net>; Tue, 11 Jan 2005 11:32:35 -0500
Received: from smtp-bedford-dr.mitre.org (localhost.localdomain [127.0.0.1])
	by smtp-bedford-dr.mitre.org (Postfix) with ESMTP id B9E7C4F8DA
	for <nfs@lists.sourceforge.net>; Tue, 11 Jan 2005 11:32:35 -0500 (EST)
Received: from linus.mitre.org (linus.mitre.org [129.83.10.1])
	by smtp-bedford-dr.mitre.org (8.11.6/8.11.6) with ESMTP id j0BGWZ626627
	for <nfs@lists.sourceforge.net>; Tue, 11 Jan 2005 11:32:35 -0500
Received: from [127.0.0.1] (unity-17-71.mitre.org [129.83.17.71])
	by linus.mitre.org (8.12.10/8.12.10) with ESMTP id j0BGWY4o003159
	for <nfs@lists.sourceforge.net>; Tue, 11 Jan 2005 11:32:35 -0500 (EST)
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

I've read the FAQ.  A lot of the information is not very
specific as to affected versions:

Is there any (or can anyone take 5 minutes to write up)
timeline that lists the major obvious problems throughout
2.4.21 to 2.6.9 and where they were fixed and enabled
(NOT experimental) in the kernel?

Things like the "file corruption when very rapid writes
from different clients leave the file size unchanged"
bug, rsize/wsize problems, etc.

Thanks for any info.



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
