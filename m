From: "ankit gala" <ankit1a@hotmail.com>
Subject: NFS recompilation error
Date: Sat, 17 May 2003 06:43:03 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Law9-F613KVLAaKHQ6m00026813@hotmail.com>
Mime-Version: 1.0
Content-Type: text/html
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f61.law9.hotmail.com ([64.4.9.61] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GvPR-0005Ze-00
	for <nfs@lists.sourceforge.net>; Fri, 16 May 2003 23:43:09 -0700
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

<html><div style='background-color:'><DIV>&nbsp;</DIV>
<DIV>
<DIV>I am&nbsp;trying to recompile the nfsd kernel module.</DIV>
<DIV>&nbsp;</DIV></DIV>
<DIV>I&nbsp;got this error when&nbsp;I tried to compile the nfsd modules by changing SUBDIRS=fs/nfsd in Makefile in /usr/src/linux-2.4.7-10/</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>
<P class=MsoPlainText style="MARGIN: 0in 0in 0pt"><SPAN style="mso-fareast-font-family: 'MS Mincho'"><FONT size=2><FONT face="Courier New">In file included from nfsfh.c:11:<BR>/usr/src/linux-2.4.7-10/include/linux/sched.h:6: nondigits in number and not hexadecimal<BR>/usr/src/linux-2.4.7-10/include/linux/sched.h:6: nondigits in number and not hexadecimal<BR>/usr/src/linux-2.4.7-10/include/linux/sched.h:6: parse error before `7b16c344'<BR>/usr/src/linux-2.4.7-10/include/linux/sched.h:6: warning: function declaration isn't a prototype<BR>make[1]: *** [nfsfh.o] Error 1<BR>make: *** [_mod_fs/nfsd] Error 2<BR>&nbsp;<?xml:namespace prefix = o ns = "urn:schemas-microsoft-com:office:office" /><o:p></o:p></FONT></FONT></SPAN></P></DIV>
<DIV>&nbsp;</DIV>
<DIV>Any&nbsp;idea what could be the problem?</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks,</DIV>
<DIV>Ankit</DIV></div><br clear=all><hr>Mobile, masti, magic! Cool ringtones & logos.  <a href="http://g.msn.com/8HMFENIN/2755??PS=">Get noticed</a> </html>


-------------------------------------------------------
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
