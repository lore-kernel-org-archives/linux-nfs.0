From: rnews@tasking.nl
Subject: Re: inconsistencies in nfs(5)
Date: Fri, 10 Aug 2007 08:18:54 -0000
Message-ID: <5e6a.46bc1f6e.593b@altium.nl>
References: <46BB2DF2.1050501@oracle.com> <169a.46bb3b18.7157f@altium.nl>
	<169a.46bb3b18.7157f@altium.nl> <46BB405B.5050206@oracle.com>
Reply-To: Dick Streefland <dick.streefland@altium.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJPi1-0005qZ-Nr
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 01:19:01 -0700
Received: from ns2.tasking.nl ([195.193.207.10])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJPi1-0001tE-PZ
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 01:19:03 -0700
Received: from greve.tasking.nl (nl-fg300a-2-dmz.tasking.nl [172.16.1.9])
	by ns2.tasking.nl (8.13.8/8.13.8) with ESMTP id l7A8IsiP028441
	for <nfs@lists.sourceforge.net>; Fri, 10 Aug 2007 10:18:54 +0200 (MEST)
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
| This is still in utils/mount/nfsmount.c.

It is not in util-linux-ng-2.13-rc2 anymore, which is in Debian sid.

| I'm not sure how this can affect other mount commands running 
| concurrently on the same client.  The man page implies that if one mount 
| command has backgrounded against a server, subsequent mount commands 
| against the same server will just go right into the background.  But 
| prev_bg_host is unique in each instance of the mount command.
| 
| Can you help me understand what you intended?  Do you have a test case?

Phew, I wrote that 10 years ago! But I think that when you do a
"mount -atnfs", multiple mounts will be handled by the same mount
instance. The code helps when there are multiple NFS mounts from the
same host in fstab, and the server is down when you boot the client.

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
