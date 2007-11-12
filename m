From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] Enable text-based mounts in mount.nfs
Date: Mon, 12 Nov 2007 12:46:12 -0500
Message-ID: <20071112172835.3134.36815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IrdMW-0001Rh-SI
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:46:16 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IrdMa-0003Ol-Bn
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:46:22 -0800
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

Hi Steve-

Sorry for posting a single patch with a cover letter (a practice normally
frowned upon).

Here's the mount.nfs change that makes text-based NFS mounts the default,
deprecating the old legacy mount ABI for 2.6.23 kernels and later.  It's
best to get this into the code base for people to start using long before
you plan to cut a new release of nfs-utils.

Text-based NFS mounts, as you know, are required to enable several upcoming
advanced NFS features, such as IPv6 support, NFS over RDMA, and local disk
caching.  It will also make it simple to add support for new NFS mount
options.

The 2.6.23 kernel's text-based NFS mount support works for many basic
configurations.  There are some regression nits that are cleaned up in
2.6.24.

Btw, will you continue hosting the nfs-utils git repository on
linux-nfs.org?

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
