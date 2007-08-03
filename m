From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] More mount.nfs clean-ups (and repost of earlier
	patches)
Date: Fri, 03 Aug 2007 13:23:23 -0400
Message-ID: <20070803171004.3357.27721.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0ry-0001uP-7K
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:22 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0s2-0007St-2D
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:26 -0700
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

Note: This patch series contains several patches that have already been
posted to the list.

The first two patches are reposted (with a few minor clean-ups) from the 23
patch series from last week.  The third patch fixes a problem with recent
changes to umount.nfs that introduced a minor firewall incompatibility.

As well as a handful of minor fixes, this series also includes two important
fixes:

1.  Make "bg" mounts work in the mount.nfs helper, and

2.  Allow TCP connect time outs to be tunable for GETPORT, clnt_ping, and
    mnt_openclnt

There has been recent discussion on the list about what transport should be
used for GETPORT calls, but I haven't included any patches in this series
to change the current behavior.

As always, constructive review is welcome from all.

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
