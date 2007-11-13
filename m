From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/25] RFC: AF_INET6 family support for the NFS client
Date: Tue, 13 Nov 2007 13:30:59 -0500
Message-ID: <20071113182226.5087.77009.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0XN-0000HW-NV
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:01 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0XT-0007A7-G4
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:07 -0800
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

These 25 patches add support for AF_INET6 addresses to the NFS client.
This is a request for review of the proposed changes.

This series does not add support for AF_INET6 addresses to the Linux
NLM or NSM implementations, nor does it add support in the NFS server.

To use an IPv6 NFS server, the mount.nfs command will pass in an IPv6
server address via the "addr" option.  IPv6 support in mount.nfs is yet
to be implemented.

This series has been tested only with IPv4 addresses to ensure there are no
regressions.  Groupe Bull has tested earlier versions of these changes with
other IPv6 NFS server implementations to sanity check the architecture.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
