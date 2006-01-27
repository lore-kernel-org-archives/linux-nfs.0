From: "Wally Winchester" <wally_winchester@fastmail.fm>
Subject: [SOLVED] Re: Stale nfs file handle - cwd without path -
   workaround?
Date: Fri, 27 Jan 2006 11:32:20 +0000
Message-ID: <1138361540.18038.252899961@webmail.messagingengine.com>
References: <1137402966.3299.251938119@webmail.messagingengine.com>
   <200601170043.18048.bernd-schubert@gmx.de>
   <1137573819.15439.252122025@webmail.messagingengine.com>
   <1137618350.8706.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2Rq4-0000zJ-Ai
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 03:32:24 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F2Rq3-0003zU-3W
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 03:32:24 -0800
Received: from frontend1.internal (mysql-sessions.internal [10.202.2.149])
	by frontend1.messagingengine.com (Postfix) with ESMTP id 54CD1D3187E
	for <nfs@lists.sourceforge.net>; Fri, 27 Jan 2006 06:32:20 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <1137618350.8706.27.camel@lade.trondhjem.org>
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


The problem was related to vmware's locking. Disabling locking makes the
problem go away (heartbeat handles the locking).

On failover, no delay. On failback, 15 minute delay - each time.

Where is this 15 minutes delay coming from and can it be tweaked?

Thanks very much :)
-- 
  Wally Winchester
  wally_winchester@fastmail.fm

-- 
http://www.fastmail.fm - Or how I learned to stop worrying and
                          love email again



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
