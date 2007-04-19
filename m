From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS caching bug is back
Date: Thu, 19 Apr 2007 14:22:55 -0400
Message-ID: <1177006975.6623.8.camel@heimdal.trondhjem.org>
References: <46278E27.8050705@atmos.washington.edu>
	<4627980C.2090308@serpentine.com>
	<4627AFB7.2080602@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Bryan O'Sullivan <bos@serpentine.com>, nfs@lists.sourceforge.net
To: David Warren <warren@atmos.washington.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HebHi-0000oG-VC
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:23:11 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+VUCpMNgbFHEZozk1MLjGIMeKeLSZI3N8=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HebHk-0003Hg-TL
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:23:13 -0700
In-Reply-To: <4627AFB7.2080602@atmos.washington.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-04-19 at 11:06 -0700, David Warren wrote:

> I don't know that much about the inner workings of the NFS protocol,
> but considering that the inode has been removed and replaced by a new
> one shouldn't all the return values from the access request be 0? It
> seems odd that read, modify, extend and execute are allowed for a
> nonexistent object.

The filehandle should normally be invalidated and any attempt by the
client to use it should result in an ESTALE error. The exception would
be if a hard link to the file still exists somewhere on the filesystem
(which didn't seem to be the case in your test).

Irrespective of whether or not the file still exists somewhere else, the
mtime on the parent directory _will_ change when you unlink the file.
The client is supposed to pick up on this and re-issue a LOOKUP and/or
OPEN for the file, at which point the server should reply with an ENOENT
or with the new file and its filehandle in something like your testcase.

My immediate advice would be to take the whole filesystem offline and
fsck it just in order to be sure that there are no corruption that might
be confusing the NFS server.

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
