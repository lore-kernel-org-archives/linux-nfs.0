From: =?iso-8859-1?q?Hank=20Shah?= <hankshah@yahoo.co.in>
Subject: How to intercept NFS requests
Date: Sun, 27 Apr 2003 11:27:28 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030427102728.37018.qmail@web8206.mail.in.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web8206.mail.in.yahoo.com ([203.199.70.75])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 199jNd-0006tA-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Apr 2003 03:27:33 -0700
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

   
   hi,
   We are trying to go through the NFS procedures to
intercept file requests so that if the files are not
available with the NFS server,we would be able to
fetch it from some other location and make that file
available on the server's disk physically.To do this
we need to know the point where the NFS server checks
to see if a file is present or not.If not then it
would call our procedure to fetch a file from the
appropriate location.That file would now be used by 
the NFS server to serve its clients.

Any ideas how to go about it?

Thanks- 
 HANKS.

=====
H arshit  Shah
A nkit    Shah
N ishit   Shah
K rushita Shah

________________________________________________________________________
Missed your favourite TV serial last night? Try the new, Yahoo! TV.
       visit http://in.tv.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
