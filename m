From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS hangs
Date: Tue, 26 Jun 2007 17:54:34 -0400
Message-ID: <1182894874.12836.48.camel@heimdal.trondhjem.org>
References: <32209efe0706251556x6894a5ddmba757984cd80f499@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Natalie Protasevich <protasnb@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3Izh-0002A6-5f
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 14:54:41 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19F6jY4D4FdZoekvQQnCyw4H/IqaUq0J8E=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3Izk-0000jk-BC
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 14:54:44 -0700
In-Reply-To: <32209efe0706251556x6894a5ddmba757984cd80f499@mail.gmail.com>
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

On Mon, 2007-06-25 at 15:56 -0700, Natalie Protasevich wrote:
> Hello,
> We have a case of system hang when many httpd and nfs processes are
> stuck trying to get the lock.
> We took a trace with sysrq-t and here it is attached.
> Thanks,
> --Natalie

What kernel etc are you running on?

I can't see that NFS is doing anything special here. Most of these httpd
processes appear to be waiting for a lock that is blocked on the server.
One appears to be waiting for posix_lock_file_wait(), which would
probably mean that it is waiting on a lock that is known to be held by
another process on that machine.

Do you know which files these processes are attempting to lock, and have
you checked using /proc/locks whether or not a lock is indeed being held
on that file on the server?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
