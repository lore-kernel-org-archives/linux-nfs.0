From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: What's up with those fractional-second mtimes?
Date: Tue, 15 May 2007 10:32:04 -0400
Message-ID: <1179239524.6464.26.camel@heimdal.trondhjem.org>
References: <loom.20070515T045905-915@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: David Wuertele <dave-gmane@bfnet.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hny4X-0005Yk-3T
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:32:17 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX187RcS8TojZ+U7qyHNDmLQ6dQjTL+/ujcY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hny4Z-0003HX-2f
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:32:20 -0700
In-Reply-To: <loom.20070515T045905-915@post.gmane.org>
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

On Tue, 2007-05-15 at 03:04 +0000, David Wuertele wrote:
> I'm trying to deploy a make-based build system to some x86_64 RHEL-4 ES boxes
> that mount their build directories NFS.  I'm having problems because timestamps
> seem to be recorded in fractions of a second, but the timestamps aren't always
> copied that way with cp -a or gzip.  Here is an example with gzip:
> 
> $ dd if=/dev/zero of=test bs=1024 count=1024
> 1024+0 records in
> 1024+0 records out
> $ stat test
>   File: `test'
>   Size: 1048576   	Blocks: 2056       IO Block: 32768  regular file
> Device: 26h/38d	Inode: 15119606    Links: 1
> Access: (0644/-rw-r--r--)  Uid: (10059/  qwv684)   Gid: (10001/ma29cu01)
> Access: 2007-05-14 22:48:01.058211000 -0400
> Modify: 2007-05-14 22:57:28.468235000 -0400
> Change: 2007-05-14 22:57:28.468235000 -0400
> $ gzip test
> $ stat test.gz
>   File: `test.gz'
>   Size: 1056      	Blocks: 8          IO Block: 32768  regular file
> Device: 26h/38d	Inode: 6176375     Links: 1
> Access: (0644/-rw-r--r--)  Uid: (10059/  qwv684)   Gid: (10001/ma29cu01)
> Access: 2007-05-14 22:48:01.000000000 -0400
> Modify: 2007-05-14 22:57:28.000000000 -0400
> Change: 2007-05-14 22:57:49.431252000 -0400
> 
> See how the mtime didn't get propogated perfectly?  The fraction after the
> decimal was truncated to zero!  This seems to happen only on the x86_64 boxes.
> 
> What is up with that?  Can I disable fractional timestamps?  Can I enable proper
> processing of them?

Sounds like a bug in 'cp'. Could you try using 'strace' to sniff if they
are really using the 'utimes()' call (rather than the 'utime()' call,
which only has a 1 second resolution) then sniff what they are sending
as arguments?

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
