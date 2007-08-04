From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: mount.nfs4 clientaddr= option inconsistent behaviour
Date: Sat, 04 Aug 2007 17:33:49 +0200
Message-ID: <46B49C5D.7070803@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: nfsv4@linux-nfs.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IHLdZ-0005Cx-9K
	for nfs@lists.sourceforge.net; Sat, 04 Aug 2007 08:33:53 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IHLdb-00022n-HI
	for nfs@lists.sourceforge.net; Sat, 04 Aug 2007 08:33:57 -0700
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

Hi,

There is an inconsistent behaviour of mount.nfs4 regarding how to 
detect/handle the client IP address.
The "clientaddr" option is allowed for mount.nfs4, but this address is 
not used for the client IP address, and if there is any DNS failure or 
misconfiguration, mount.nfs4 will fail.

The error is in get_my_ipv4addr() at nfs4mount.c:170 (nfs-utils-1.1.0). 
This function fills *ip_addr with the client address, detected from the 
resolved machine name (gethostname() which is tried to be resolved in 
fill_ipv4_sockaddr). This cannot work if the machine name is not (yet) 
properly resolvable in DNS at mount time (e.g. we are nfs4-mounting the 
root filesystem very early). Using the clientaddr option provided before 
trying to resolve the gethostname() hostname, would be IMHO a more 
consistent behaviour.

This can cause much trouble too with multihomed clients. The right way 
would be to detect the client IP from the server IP (or resolved IP) 
(and deal with clients with multiple addresses per subnet, by taking the 
lowest address only)

Patch for this is easy (the first part, not the ip detection code), and 
can be provided if necessary.

Gabriel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
