From: Jonas Oberg <jonas@informatik.gu.se>
Subject: Too many mounts
Date: Thu, 06 Mar 2003 14:52:22 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87adg8iovd.fsf@fiona.informatik.gu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from fiona.informatik.gu.se ([130.241.141.27] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18qvno-0003XA-00
	for <nfs@lists.sourceforge.net>; Thu, 06 Mar 2003 05:52:52 -0800
Received: from jonas by fiona.informatik.gu.se with local (Exim 3.36 #1 (Debian))
	id 18qvnL-0007tk-00
	for <nfs@lists.sourceforge.net>; Thu, 06 Mar 2003 14:52:23 +0100
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

In our department we have a problem with our student server. It
appears that the Linux kernel limits the number of anonymous (nfs
et. al) mounts to 256. This is a problem for us, since we use
automount to mount home directories from our fileserver via NFS. We
are frequently in the range of 190-220 active mounts (we have set the
automount timeout to be about 30 seconds to get rid of idle mounts
quickly).

Does anyone have a solution for this problem? Would using devfs
perhaps solve the problem by allowing more anonymous mounts?

-- 
Jonas Öberg
Systems administrator/webmaster, Department of Informatics,
School of Economics and Commercial Law, Gothenburg University.
Phone. +46-31-7732717, Fax. +47-31-7734754


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
