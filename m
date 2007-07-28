From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/23]
Date: Sat, 28 Jul 2007 17:49:06 -0400
Message-ID: <20070728213611.21871.4021.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAU-0007Qa-Qg
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:46 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAY-0003Yj-NV
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:50 -0700
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

Hi Neil-

During my continuing effort to familiarize myself with the current mount.nfs
code base, I've run across some minor issues for which I've created a set of
patches.  These refactor, clarify, and modernize some areas of mount and
umount operation.

As always, constructive comments are welcome from all.

I'm continuing to look at fg/bg and at building string-ified mounting.  I am
focusing on these clean-ups and bug fixes because it is clear that mount.nfs
is what distributions will use now instead of the old util-linux mount.  Thus
mount.nfs must work as well as or better than the old mount command before we
move forward with string-ified mount option handling.

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
