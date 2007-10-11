From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Wed, 10 Oct 2007 21:23:56 -0500
Message-ID: <20071011022356.3501.63859.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfnnJ-00078J-3N
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:29:01 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfnnM-0007cl-7G
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:29:06 -0700
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

This patchset implements cleanup that is primarily driven by Greg Bank's 
review of the transport switch. A summary follows:

- Fix the svc_create_xprt to properly allocate the temporary sockaddr storage
  necessary for IPv6.
 
- Fix the svc_find_xprt service to lock the sv_permsocks list

- Fix the svc_find_xprt service to handle the address family correctly
  when matching the port number on IPv6 connections.

Thanks Greg.

Other changes include:

- Use the svc_find_xprt service to support adding and removing knfsd transports
  by writing strings to the /proc/fs/nfs/portlist file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
