From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: Re: nfs over TCP stable?
Date: Mon, 05 May 2003 21:49:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EB6C066.30902@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp4.wanadoo.es ([62.37.236.138] helo=smtp.wanadoo.es)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ClyS-0006ck-00
	for <nfs@lists.sourceforge.net>; Mon, 05 May 2003 12:50:08 -0700
Received: from wanadoo.es ([80.103.136.196])
	by smtp.wanadoo.es (8.12.8/8.12.8) with ESMTP id h45JtFwX000505
	for <nfs@lists.sourceforge.net>; Mon, 5 May 2003 21:55:16 +0200
To: nfs <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Steve Dickson wrote:

>It has been suggested to me, I and think I agree, that the
>I/O processing of the NFS server should be broken up into
>to threads. A RX and TX thread. With the idea being when the
>TX thread starts to get backed up, it turns off the RX thread
>(i.e. stops it from receiving) which in turn will flow-control
>sending client. This should allow the TX thread to be able
>to catch up...

2.5.xx has the same problem?

-thanks-

regards,
-- 
Galiza nin perdoa nin esquence. Governo demision!



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
