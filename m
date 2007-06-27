From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: How best to handle implicit clearing of
	setuid/setgid	bits on NFS?
Date: Wed, 27 Jun 2007 18:15:55 -0400
Message-ID: <1182982555.5311.67.camel@heimdal.trondhjem.org>
References: <20070529124705.a1e70735.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3fnt-0001eq-M0
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 15:16:01 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+Jc8d2UGhySsftLGWHY2GVozqSEtI5ZZA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3fnu-0006XU-67
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 15:16:05 -0700
In-Reply-To: <20070529124705.a1e70735.jlayton@redhat.com>
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

On Tue, 2007-05-29 at 12:47 -0400, Jeff Layton wrote:
> I've been looking at issue of clearing setuid/setgid bits when a file
> is written to on NFS. Here's the problem in a nutshell:
> 
> We have 2 users. test1 and test2. Both are members of the group
> "testgrp":
> 
> test2@host$ ls -l f1
> -rwxrwsr-x 1 test1 testgrp 2 2007-05-29 12:23 f1
> test2@host$ echo foo > f1
> -bash: f1: Permission denied
> 
> ...and f1 is unchanged. The problem is that the VFS calls remove_suid
> to wipe the setgid bit. This ends up causing a SETATTR call, which
> fails on NFS because we're attempting to remove these bits as user
> "test2".
> 
> Until recently, the situation here was worse. The VFS would truncate
> the file first and then try to clear the setgid bit. The truncate would
> succeed, but the perm change would fail. You'd end up with a zero-length
> file. This was fixed my making the size change and bit-clearing go via
> the same setattr call, so the whole operation just errors out now.
> 
> My question is -- Is there anything we can do to make this work as it
> does on a local filesystem? Ideally there would be some way to tell the
> server "clear the setuid/gid bits", without actually modifying the
> contents of the file. Is there a NFS call we can use that would do this?
> 
> The only thing I can think of is to read the first byte of the file and
> then overwrite it with the same data, but that seems racy and may have
> other problems (and what do you do with a zero-length, setuid file?).
> 
> Any suggestions appreciated...

The answer should be simple: leave it to the server. All servers I know
(except possibly Hummingbird) will clear the setuid/setgid bit whenever
the file is modified. Anything else would be _extremely_ racy anyway:
Consider the scenario where you are preparing to write to the file, when
suddenly a user on another client makes the file setuid after you have
open()ed the file, but before you actually issue the write().

IOW: calling remove_suid() on the client is completely redundant, and
should be suppressed.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
