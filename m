From: Abhishek Rai <abbashake007@yahoo.com>
Subject: nfs client's usage of linux pagecache
Date: Fri, 4 Apr 2003 02:49:14 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030404104914.79289.qmail@web11405.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web11405.mail.yahoo.com ([216.136.131.235])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191Ol1-0001UF-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Apr 2003 02:49:15 -0800
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

hi everybody,
i m doing some performance evaluation of linux nfs
client and for that would like to know the client's
usage of linux pagecache at any given time. could sb
tell me how to go ab't doing that. Is the slabinfo of
'nfs_read_data', 'nfs_inode_cache', 'nfs_write_data',
'nfs_page' of any use ? (/proc/meminfo didn't turn out
to be of much use to me).
thanks a lot
abhishek

========================================================
So you run and run, to catch up with the sun
Which is going round, to rise again tomorrow
Tomorrow, the sun is the same - at least in a relative
way,
But you, are shorter of breath and a day closer to
death

Abhishek Rai
Final Yr, B. Tech, Computer Sc.
IIT Kharagpur
India

__________________________________________________
Do you Yahoo!?
Yahoo! Tax Center - File online, calculators, forms, and more
http://tax.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
