From: Thomas Wallis <wallis@cs.wichita.edu>
Subject: NFS weirdness in recent LINUX 2.4-series kernels using am-utils
Date: Thu, 2 Dec 2004 12:28:43 -0600 (CST)
Message-ID: <Pine.LNX.4.44.0412021213590.4229-100000@q.cs.wichita.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Thomas W. Wallis" <wallis@cs.wichita.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CZvhh-0003nH-To
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 10:29:21 -0800
Received: from pobox.cs.wichita.edu ([156.26.10.25] ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CZvhh-0004k4-Ac
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 10:29:21 -0800
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

	Dear NFS users:

	I have been seeing strange behavior with Debian 3.0, am-utils
6.0.7-6 and NFS under 2.4.x, especially 2.4.26 - 2.4.28.

	The automounter often hangs or times out trying to access
filesystems on various LINUX servers.  One of the servers is running
2.4.28, the other is running 2.4.27.  As an example, a user may be logging
into a box that has their home directory NFS-mounted via am-utils.
The first login attempt will give them no home directory.  But if they
wait a little while and try again, eventually it will work!  Manual
NFS mounts seem to work fine.  On the client, we normally get repeated

"nfs_stat_to_errno: bad nfs status return value: 11"

in the syslogs.  On the server, there seems to be nothing unusual in the
syslogs.  The problem seems to be worst immediately after rebooting a
client.

Any ideas?

				Thanks in advance,

				Thomas Wallis


Disclaimer: All opinions expressed here are my own and not those of WSU.

EMAIL address:  wallis@cs.wichita.edu






-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
