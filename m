From: Jack Sparrow <jack_sparrow81@yahoo.com>
Subject: reply cache question
Date: Mon, 29 Sep 2003 04:30:54 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030929113054.12150.qmail@web20505.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A3wFn-000706-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Sep 2003 04:31:47 -0700
Received: from [216.136.226.140] (helo=web20505.mail.yahoo.com)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A3wFm-0002Gg-72
	for nfs@lists.sourceforge.net; Mon, 29 Sep 2003 04:31:46 -0700
To: nfs@lists.sourceforge.net
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

Hi all,
    I looked at a lot of NFS- HA configurations on
this mailing list, which mostly use shared storage.
But none of them talk about the synchornisation of the
reply cache on the NFS server. why is it so ?
    The only reference I found to the reply cache
synchronisation is at 

http://www-2.cs.cmu.edu/~mootaz/hanfs.html
    Is it the case that all the other references to
nfs-HA totally neglect reply cache ? is it correct ?

thanks in advance.

Jack.

__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
