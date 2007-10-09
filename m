From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 0/7] svc: Incremental svc patchset cleanup
Date: Tue, 09 Oct 2007 10:35:39 -0500
Message-ID: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfH8v-0005cb-UB
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:10 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfH8z-0000Cn-P1
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:15 -0700
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

This patchset is a series of independent, incremental patches against
the previously posted svc transport switch patchset. I believe each
of these patches can be taken independently. They are presented as a 
series soley because they reflect what I believe to be the collective 
consensus of the svc transport switch review.

The main, non-trivial changes are as follows:

- Transport class data is no longer copied to each transport instance.

- A svc_xprt_find service has been added to allow a service to query
  for transport instances based on class name, address family and port.

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
