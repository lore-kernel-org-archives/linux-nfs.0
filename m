From: rnews@tasking.nl
Subject: Re: inconsistencies in nfs(5)
Date: Thu, 09 Aug 2007 16:04:40 -0000
Message-ID: <169a.46bb3b18.7157f@altium.nl>
References: <46BB2DF2.1050501@oracle.com>
Reply-To: Dick Streefland <dick.streefland@altium.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJAVF-0003Gb-Lp
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 09:04:49 -0700
Received: from ns2.tasking.nl ([195.193.207.10])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJAVH-000775-40
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 09:04:53 -0700
Received: from greve.tasking.nl (nl-fg300a-2-dmz.tasking.nl [172.16.1.9])
	by ns2.tasking.nl (8.13.8/8.13.8) with ESMTP id l79G4eRf026997
	for <nfs@lists.sourceforge.net>; Thu, 9 Aug 2007 18:04:41 +0200 (MEST)
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

Chuck Lever <chuck.lever@oracle.com> wrote:
| +  The description for the "bg" option claims "After a mount operation 
| is backgrounded, all subsequent mounts on the same NFS server will be 
| backgrounded immediately, without first attempting the mount."  I don't 
| think there's logic to do that in either the legacy mount command or in 
| mount.nfs.  Should this text be removed from the man page?

I added that text in 1997, in a patch that was included in mount-2.7g.
It referred to the following fragment in nfsmount.c:

+       /*
+        * If the previous mount operation on the same host was
+        * backgrounded, and the "bg" for this mount is also set,
+        * give up immediately, to avoid the initial timeout.
+        */
+       if (bg && !running_bg &&
+           prev_bg_host && strcmp(hostname, prev_bg_host) == 0) {
+               if (retry > 0)
+                       retval = EX_BG;
+               return retval;
+       }

This code got removed somewhere after util-linux-2.12p, but I don't
know the details.

-- 
Dick Streefland                      ////                      Altium BV
dick.streefland@altium.nl           (@ @)          http://www.altium.com
--------------------------------oOO--(_)--OOo---------------------------


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
