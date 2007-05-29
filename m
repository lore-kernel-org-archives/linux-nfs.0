From: Jeff Layton <jlayton@redhat.com>
Subject: How best to handle implicit clearing of setuid/setgid bits on
	NFS?
Date: Tue, 29 May 2007 12:47:05 -0400
Message-ID: <20070529124705.a1e70735.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ht4qm-0002z3-Bg
	for nfs@lists.sourceforge.net; Tue, 29 May 2007 09:47:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ht4qp-0001KE-5k
	for nfs@lists.sourceforge.net; Tue, 29 May 2007 09:47:15 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l4TGl6wA009884
	for <nfs@lists.sourceforge.net>; Tue, 29 May 2007 12:47:06 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l4TGl6vS029990
	for <nfs@lists.sourceforge.net>; Tue, 29 May 2007 12:47:06 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l4TGl5cj014500
	for <nfs@lists.sourceforge.net>; Tue, 29 May 2007 12:47:05 -0400
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

I've been looking at issue of clearing setuid/setgid bits when a file
is written to on NFS. Here's the problem in a nutshell:

We have 2 users. test1 and test2. Both are members of the group
"testgrp":

test2@host$ ls -l f1
-rwxrwsr-x 1 test1 testgrp 2 2007-05-29 12:23 f1
test2@host$ echo foo > f1
-bash: f1: Permission denied

...and f1 is unchanged. The problem is that the VFS calls remove_suid
to wipe the setgid bit. This ends up causing a SETATTR call, which
fails on NFS because we're attempting to remove these bits as user
"test2".

Until recently, the situation here was worse. The VFS would truncate
the file first and then try to clear the setgid bit. The truncate would
succeed, but the perm change would fail. You'd end up with a zero-length
file. This was fixed my making the size change and bit-clearing go via
the same setattr call, so the whole operation just errors out now.

My question is -- Is there anything we can do to make this work as it
does on a local filesystem? Ideally there would be some way to tell the
server "clear the setuid/gid bits", without actually modifying the
contents of the file. Is there a NFS call we can use that would do this?

The only thing I can think of is to read the first byte of the file and
then overwrite it with the same data, but that seems racy and may have
other problems (and what do you do with a zero-length, setuid file?).

Any suggestions appreciated...

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
