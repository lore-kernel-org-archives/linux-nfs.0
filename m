From: jrc@skylon.demon.co.uk
Subject: Re; Strange serialisation with slow operations?
Date: Fri, 26 Sep 2003 10:30:12 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A2ovU-0005yN-0b@anchor-post-37.mail.demon.net>
Reply-To: jrc@skylon.demon.co.uk
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Tried the same test using a Solaris 8 client and didn't experience the
blocking behaviour.  Ethereal shows that "cat a" used UDP ports:
2049;1023 and that "cat b" used ports 2049;1022.

This suggests to me that perhaps the blocking is occuring at the UDP
level.  Any comments?
--
John Connett



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
