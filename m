From: Charles Meier <cmeier@peerpro.net>
Subject: mountd
Date: Mon, 20 Dec 2004 23:10:15 -0500
Message-ID: <41C7A227.2080101@peerpro.net>
Reply-To: cmeier@peerpro.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CgbWl-0002n6-Sf
	for nfs@lists.sourceforge.net; Mon, 20 Dec 2004 20:21:39 -0800
Received: from ms-smtp-03-smtplb.ohiordc.rr.com ([65.24.5.137] helo=ms-smtp-03-eri0.ohiordc.rr.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CgbWj-0000mf-RI
	for nfs@lists.sourceforge.net; Mon, 20 Dec 2004 20:21:39 -0800
Received: from peerpro.net (dhcp233019.columbus.rr.com [204.210.233.19])
	by ms-smtp-03-eri0.ohiordc.rr.com (8.12.10/8.12.7) with ESMTP id iBL4LYwZ020289
	for <nfs@lists.sourceforge.net>; Mon, 20 Dec 2004 23:21:34 -0500 (EST)
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


Is there a reason that the call to xlog_open has been commented
out in mountd/mountd.c?  xlog_open wants to use the LOG_DAEMON
facility opened with syslog's openlog().  If no facility is
specified (as here), syslog dumps messages to a catch-all
LOG_USER facility.   exportfs/exportfs.c, OTOH, does call
xlog_open().

-- 
Charles Meier
cmeier@peerpro.net



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
