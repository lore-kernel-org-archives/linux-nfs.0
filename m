From: Mark Goodwin <markgw@sgi.com>
Subject: empty /etc/exports causes nfs rc script to exit
Date: Mon, 3 Feb 2003 11:31:21 +1100 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302031125590.16330-100000@sherman.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from zok.sgi.com ([204.94.215.101])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fUWB-0007qC-00
	for <nfs@lists.sourceforge.net>; Sun, 02 Feb 2003 16:31:23 -0800
Received: from larry.melbourne.sgi.com (larry.melbourne.sgi.com [134.14.52.130])
	by zok.sgi.com (8.12.2/8.12.2/linux-outbound_gateway-1.2) with SMTP id h12NcEKp001087
	for <@external-mail-relay.sgi.com:nfs@lists.sourceforge.net>; Sun, 2 Feb 2003 15:38:15 -0800
Received: from sherman.melbourne.sgi.com (sherman.melbourne.sgi.com [134.14.55.232]) by larry.melbourne.sgi.com (950413.SGI.8.6.12/950213.SGI.AUTOCF) via ESMTP id LAA04263 for <nfs@lists.sourceforge.net>; Mon, 3 Feb 2003 11:31:21 +1100
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


Is there some good reason why the nfs rc script exits if /etc/exports
is empty?  [ -s /etc/exports ] || exit 0

If an admin adds something to /etc/exports, they have to kick the
rc script too. Seems silly.

-- Mark



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
