From: Fabrizio Nesti <nesti@medialab.sissa.it>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Wed, 19 Feb 2003 16:27:00 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.40.0302191520180.29315-100000@bodoni>
References: <200302191407.h1JE7DbU026781@buggy.badula.org>
Reply-To: Fabrizio Nesti <nesti@medialab.sissa.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from didot.sissa.it ([147.122.2.50])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lWBk-0002JD-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 07:31:12 -0800
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <200302191407.h1JE7DbU026781@buggy.badula.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> Is RH8.0 using nfs-utils 1.0 or newer?

1.0.1..

> If so, then the default server export options have changed and the
> filesystem is now exported "sync", instead of "async".

Yes we exported it async :) as confirmed by the snoop that I reported
earlier. See it also below. But nothing changed.

> The other thing to remember is that "cto"...
> ...

On the solaris client? It is not in the man mount_nfs, but it
worked. However there was no performance upgrade.

Also, I can't recognize it in the old traffic snoop..
I report below some of it during the write of one file from tar.

...It must be something really more crucial, for a performance upgrade of
3-5 times..

A clue seems this now: the "tar" process itself on solaris uses 4% cpu while
writing on a local disk, and 40% and over while writing to the nfs disk...
(not using -z gzip:) Also, mounting nfs2 seems 30% faster.. But we do not
understanf the reason.

Fabrizio


PS: Excerpt from network traffic during "tar"

    solaris -> linux     NFS C LOOKUP3 FH=884D Makefile.in
  linux -> solaris       NFS R LOOKUP3 No such file or directory
    solaris -> linux     NFS C LOOKUP3 FH=884D Makefile.in
  linux -> solaris       NFS R LOOKUP3 No such file or directory
    solaris -> linux     NFS C CREATE3 FH=884D (EXCLUSIVE) Makefile.in
  linux -> solaris       NFS R CREATE3 OK FH=174A
    solaris -> linux     NFS C SETATTR3 FH=174A
  linux -> solaris       NFS R SETATTR3 OK
    solaris -> linux     NFS C WRITE3 FH=174A at 0 for 8192 (ASYNC)
    solaris -> linux     TCP D=2049 S=793 ..   Len=1460 Win=24820
    solaris -> linux     TCP D=2049 S=793 ..  Len=1460 Win=24820
    solaris -> linux     TCP D=2049 S=793 .. Len=1460 Win=24820
    solaris -> linux     TCP D=2049 S=793 .. Len=1460 Win=24820
    solaris -> linux     TCP D=2049 S=793 .. Len=1056 Win=24820
  linux -> solaris       TCP D=793 S=2049 .. Len=0 Win=40880
  linux -> solaris       NFS R WRITE3 OK 8192 (ASYNC)
    solaris -> linux     NFS C WRITE3 FH=174A at 8192 for 3260 (ASYNC)
    solaris -> linux     TCP D=2049 S=793 .. Len=1460 Win=24820
    solaris -> linux     TCP D=2049 S=793 .. Len=504 Win=24820
  linux -> solaris       TCP D=793 S=2049 .. Len=0 Win=40880
  linux -> solaris       NFS R WRITE3 OK 3260 (ASYNC)
    solaris -> linux     NFS C COMMIT3 FH=174A at 0 for 16384
  linux -> solaris       NFS R COMMIT3 OK
    solaris -> linux     NFS C LOOKUP3 FH=884D Makefile.in
  linux -> solaris       NFS R LOOKUP3 OK FH=174A
    solaris -> linux     NFS C SETATTR3 FH=174A
  linux -> solaris       NFS R SETATTR3 OK
    solaris -> linux     NFS C LOOKUP3 FH=884D Makefile.in
  linux -> solaris       NFS R LOOKUP3 OK FH=174A
    solaris -> linux     NFS C SETATTR3 FH=174A
  linux -> solaris       NFS R SETATTR3 OK





-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
