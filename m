From: jrc@skylon.demon.co.uk
Subject: Strange serialisation with slow operations?
Date: Thu, 25 Sep 2003 12:07:49 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A2TyP-0005nb-0b@anchor-post-37.mail.demon.net>
Reply-To: jrc@skylon.demon.co.uk
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2TyR-0005cz-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 04:07:51 -0700
Received: from anchor-post-37.mail.demon.net ([194.217.242.87])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2TyQ-0006vG-Bz
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 04:07:50 -0700
To: nfs@lists.sourceforge.net
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

I have encountered some perplexing behaviour with the nfs server when
using XFS + DMAPI to simulate slow operations.

Using DMAPI I have arranged for the file "a" to block for 60 seconds
before allowing the read to continue.  The file "b" is a regular file.
The filesystem is exported as

    /fs (rw)

and is mounted on the single Linux client as

    server:/fs (rw,addr=??.??.??.??)

I open two windows on the client and issue the following commands:

    window1: cd /fs
    window1: cat a
    window2: cd /fs
    window2: cat b
    window1: # blocks for ~ 60 seconds
    window1: <cat output from a>
    window2: <cat output from b>

The reason I am perplexed is the delay to the output from file "b".
Is this the expected behaviour?  And is there any way to avoid it?

The server system is running Red Hat Linux 9 for Intel with the
following RPMs:

    kernel-2.4.20-19.9.XFS1.3.0.i686.rpm
    nfs-utils-1.0.1-3.9.i386.rpm
    xfsprogs-2.5.6-0.i386.rpm
    dmapi-2.0.8-0.i386.rpm
    dmapi-devel-2.0.8-0.i386.rpm

The server is started with

    daemon rpc.nfsd 8

and ps(1) shows eight server threads.

If there is any further information I can supply to diagnose this,
please let me know ...

Many thanks in anticipation
--
John Connett



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
