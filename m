From: Michael Madore <Michael.Madore@aslab.com>
Subject: find_exported_dentry: npd != pd
Date: Thu, 10 Mar 2005 09:42:02 -0800
Message-ID: <1110476522.14523.5.camel@drevil.aslab.com>
Mime-Version: 1.0
Content-Type: text/plain
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9Rfk-0006t5-AQ
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 09:42:08 -0800
Received: from adsl-69-225-172-73.dsl.pltn13.pacbell.net ([69.225.172.73] helo=mail.aslab.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D9Rfi-0005BB-V4
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 09:42:08 -0800
Received: from drevil.aslab.com (drevil.aslab.com [192.168.2.34])
	by mail.aslab.com (Postfix) with ESMTP id 522384B19C
	for <nfs@lists.sourceforge.net>; Thu, 10 Mar 2005 09:58:32 -0800 (PST)
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

Hi,

I was running dbench from a Linux 2.6.11 NFS client to a Linux 2.6.11
NFS server and received many copies of the following message in the
server's syslog:

find_exported_dentry: npd != pd

I found the following comment in fs/exportfs/expfs.c:

/* we didn't really want npd, we really wanted
 * a side-effect of the lookup.
 * hopefully, npd == pd, though it isn't really
 * a problem if it isn't
 */

So, is this error message really harmless?  The reason I'm asking is
because a lot of users will panic upon seeing any unusual messages in
syslog.

Thanks

Mike



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
