From: Terry Bates <tbates@mainframe.ca>
Subject: nfs_stat_to_errno: bad nfs status return value: 151
Date: Fri, 05 Apr 2002 13:34:51 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CAE187B.EF7CF412@mainframe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from m106.reboot.com ([207.194.87.106] helo=wale.mainframe.ca)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16tbMJ-00063i-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Apr 2002 13:34:59 -0800
Received: from saturn.mainframe.ca (saturn [10.0.0.254])
	by wale.mainframe.ca (SGI-8.9.3/8.9.3) with SMTP id NAA23303
	for <nfs@lists.sourceforge.net>; Fri, 5 Apr 2002 13:34:52 -0800 (PST)
Received: from park.mainframe.ca ([172.16.130.30])
 by saturn.mainframe.ca (NAVGW 2.5.1.18) with SMTP id M2002040513345211893
 for <nfs@lists.sourceforge.net>; Fri, 05 Apr 2002 13:34:52 -0800
Received: from mainframe.ca (raimi.mainframe.ca [172.16.130.10])
	by park.mainframe.ca (SGI-8.9.3/8.9.3) with ESMTP id NAA37789
	for <nfs@lists.sourceforge.net>; Fri, 5 Apr 2002 13:34:51 -0800 (PST)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

We're runing RedHat 7.1 and 7.2 on various machines, and they all seem
to be getting the same errors.  It was also happening with 6.2.  Here''s
a sample from the mesages file:

Apr  5 11:55:02 rfl0002 kernel: nfs_stat_to_errno: bad nfs status return
value: 151
Apr  5 11:56:19 rfl0002 kernel: nfs_stat_to_errno: bad nfs status return
value: 151
Apr  5 11:56:19 rfl0002 kernel: nfs_stat_to_errno: bad nfs status return
value: 151

This particular machine is running RH7.1  kernel-2.4.2-2

Does anyone know what this 151 value means?



terry



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
