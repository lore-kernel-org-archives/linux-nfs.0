From: "Wendy Cheng" <wendy.cheng@falconstor.com>
Subject: NFS & 2.4 VM Performance
Date: Wed, 2 Apr 2003 13:20:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <017401c2f944$8d096250$19103942@tamarac>
Reply-To: "Wendy Cheng" <wendy.cheng@falconstor.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.105.142.2] (helo=falconstorex.falconstor.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190mqh-0000Rm-00
	for <nfs@lists.sourceforge.net>; Wed, 02 Apr 2003 10:20:35 -0800
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

We're looking into using Linux as a file server and 
would like to know more about NFS performance 
in general. If possible, we prefer 2.4.x kernel - 
unfortunately, a discussion archived in "mlist.linux.kernel" 
news group raises concerns:

http://www.ussg.iu.edu/hypermail/linux/kernel/0104.0/0598.html

It said that the 2.4 VM was lacking the ability to 
efficiently manage page fragmentation that, in turns,  
would cause few free buddied pages available for 
NFS requests, etc. Since the discussion was held 
long time ago (April 2001), I'm wondering whether 
the newer versions of kernel (say 2.4.19) has any 
fixes or patches to eliminate/alleviate the problems ?

Or should we just directly jump into 2.5.x kernel ?

Thank you for the helps.

Wendy
 


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
