From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: problem with  umount
Date: Fri, 28 Jan 2005 05:07:17 -0800 (PST)
Message-ID: <20050128130718.41929.qmail@web51609.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuVqr-0005ig-3u
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 05:07:53 -0800
Received: from web51609.mail.yahoo.com ([206.190.38.214])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CuVqO-0008P8-92
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 05:07:52 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi , 
         I have suse installed(2.6.5-7.109.12-smp)
installed on my machine.umount version 2.12
If i mount filesystems and export them
and if nfs client does some processing on filesystem
, server side sometime fails to unmount it.

But if client stays without doing any processing ,
everything works fine.
I tried using umount <filesystem> -O -l
but this does not work though man pages 
say that even if there are reference to filesystem , 
it will be unmounted and later do required cleanup.

As problem arises only when nfs client does some
processing on filesystem , there must be problem in
nfs.(must not be cleaning up all references)
I have read previous thread on " forcing umount "
Have anybody else faced the same problem ?
Is there any fix for this ?

thanks,
   kiran





		
__________________________________ 
Do you Yahoo!? 
Meet the all-new My Yahoo! - Try it today! 
http://my.yahoo.com 
 



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
