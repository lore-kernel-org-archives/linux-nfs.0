From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] NFS text-based mount clean up patches for
	2.6.23-rc
Date: Wed, 29 Aug 2007 15:49:22 -0400
Message-ID: <20070829194232.14142.9014.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTYM-0007Jn-7v
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:50:14 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTYP-0000mL-LW
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:50:18 -0700
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

Hi Trond-

I've cleaned up my clean-ups.  I've postponed the compiler warning patches
until 2.6.24 opens.  This series applies on Linus' current git tree.

These don't really change behavior, just pre-requisite clean-ups:

+ rpcb-eagain
+ rpcb-noprotoopt
+ rpcb-error-handling-cleanup

This one is a behavioral change that helps the in-kernel mount client, but may
also change how RPC ping behaves for things like the NFSv3 ACL protocol:

+ rpcb-fail-null-requests-immediately

These are the same as before:

+ nfs-fix-xprt-proto-problem
+ nfs-mount-name-too-long
+ nfs-mount-expose-errors
+ nfs-mount-distinguish-bind-errors

I'd like all of these to be included in 2.6.23-rc before it is released, if
possible, to help make the new text-based NFS mount API more usable when
2.6.23 is finally released.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
