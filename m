From: Jonathan Nicklin <jnicklin111@yahoo.com>
Subject: NFS Server Interoperability: Link and Rename
Date: Mon, 30 Sep 2002 18:39:22 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021001013922.23147.qmail@web13207.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-1516854440-1033436362=:22952"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web13207.mail.yahoo.com ([216.136.174.192])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17wC0R-0000D1-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Sep 2002 18:39:23 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

--0-1516854440-1033436362=:22952
Content-Type: text/plain; charset=us-ascii


All,

Over the last decade, there seems to have been quite a bit of discussion about whether NFS filehandles (V2/V3) are allowed to change as a result of a link or rename operation. Its appears that Linux includes the parent inode as part of the filehandle and while this does not appear to be in violation of the spec (depending on who you talk to), Im curious if anyone has noticed interoperability problems with clients on other platforms that are a result of server behavior as described above. For example, how does the Solaris v7/v8 client deal with such behavior. Its obvious that renames in the same directory would be fine, but what about cross directory renames and links?

Cheers,

Jonathan Case Nicklin





---------------------------------
Do you Yahoo!?
New DSL Internet Access from SBC & Yahoo!
--0-1516854440-1033436362=:22952
Content-Type: text/html; charset=us-ascii

<P>All,</P>
<P>Over the last&nbsp;decade, there seems to have been quite a bit of discussion about whether NFS filehandles (V2/V3)&nbsp;are allowed to&nbsp;change as a result of a link or rename operation. Its appears that Linux includes the parent inode as part of the filehandle and while this does not appear to be in violation of the spec (depending on who you talk to), Im curious if anyone has noticed interoperability problems with clients on other platforms that&nbsp;are a result&nbsp;of server behavior as described above. For example, how&nbsp;does the&nbsp;Solaris v7/v8 client deal with such behavior. Its obvious that renames in the same directory would be fine, but what about cross directory renames and links?</P>
<P>Cheers,</P>
<P>Jonathan Case Nicklin</P><BR><BR><p><br><hr size=1>Do you Yahoo!?<br>
New <a href="http://rd.yahoo.com/evt=1207/*http://sbc.yahoo.com/">DSL Internet Access</a> from SBC & Yahoo!</a>
--0-1516854440-1033436362=:22952--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
