From: "Wendy Cheng" <wendy.cheng@falconstor.com>
Subject: NFS Read Performance
Date: Sat, 22 Mar 2003 11:26:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002301c2f08f$cd30c430$19103942@tamarac>
Reply-To: "Wendy Cheng" <wendy.cheng@falconstor.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.105.142.2] (helo=falconstorex.falconstor.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18wlpM-0003Qa-00
	for <nfs@lists.sourceforge.net>; Sat, 22 Mar 2003 08:26:37 -0800
To: <nfs@lists.sourceforge.net>
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

we're conducting SPEC SFS97 benchmark runs 
to evaluate Linux performance as NFS file servers. 
It is observed that an unusual high percentage of 
benchmark time was spent in "read" operation. 
A sampled workload consisting of 18% of read 
consumes 63% of total benchmark time. Did this 
problem get analyzed before (or even better :)- 
is there a patch) ? We're on 2.4.19 kernel- NFS 
V3 - UDP, with EXT3 as local file system. 

Thanks in advance.


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
