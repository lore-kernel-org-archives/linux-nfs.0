From: Harshula <harshula@sgi.com>
Subject: libnfsidmap
Date: Tue, 23 Oct 2007 20:54:06 +1000
Message-ID: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkHOn-00081o-MW
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 03:54:13 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IkHOs-0003Dl-2h
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 03:54:19 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Bruce,

We are building nfs-utils 1.0.7 with libnfsidmap 0.20 to avoid a bug
with userid mappings in libnfsidmap 0.12.

Then we tripped over nfs/<FQDN> principals not being resolved. Luckily I
came across:
http://linux-nfs.org/pipermail/nfsv4/2006-June/004564.html

and realised that the code to handle nfs/<FQDN> principals is now in
nfs-utils (utils/gssd/svcgssd_proc.c).

Are there any other known issues we might trip over as a result of using
nfs-utils 1.0.7 with libnfsidmap 0.20?

Thanks,
#


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
