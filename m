From: Alan Powell <lakerfaniam2@yahoo.com>
Subject: number of files per directory under ext3 & directory indexing
Date: Mon, 17 Feb 2003 18:24:49 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030218022449.85354.qmail@web12202.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web12202.mail.yahoo.com ([216.136.173.86])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kxRB-0006Fm-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 18:24:49 -0800
To: nfs@lists.sourceforge.net, SteveD@RedHat.com
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

Can you share your experiences of when performance
starts dropping dramatically based on the number of
files in a directory under ext3? (assuming that you
haven't applied any directory indexing patch)

I had always thought that ext3 performed well with a
large number of files per directory, but apparently
directory indexing, which would substantially improve
performance of large directories, has yet to be added
to the kernel (submitted patch:
http://lwn.net/Articles/11481/).

We're not too keen in our company to put cutting-edge
patches into production, but we have a major
performance issue, b/c we have a bottleneck on our
highly trafficked NFS server: 246 directories, each
containing about 14,000 JPG files with an average size
of about 30Kb. So that brings me back to my original
question in the email... Thanks!


__________________________________________________
Do you Yahoo!?
Yahoo! Shopping - Send Flowers for Valentine's Day
http://shopping.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
