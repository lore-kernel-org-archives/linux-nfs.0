From: Dejan Muhamedagic <dejan@hello-penguin.com>
Subject: intermittent errors with AIX server
Date: Fri, 7 Feb 2003 12:01:55 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030207120155.B14505@smp.colors.kwc>
Reply-To: Dejan Muhamedagic <dejan@hello-penguin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pinguin13.kwc.at ([193.228.81.158] helo=mail.hello-penguin.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18h6H8-0001Bg-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Feb 2003 03:02:31 -0800
Received: from dejan by mail.hello-penguin.com with local (Exim 3.33 #3)
	id 18h6GZ-0003vt-00
	for nfs@lists.sourceforge.net; Fri, 07 Feb 2003 12:01:55 +0100
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

Hello everybody,

I've got a problem I'm not sure how to tackle.  Few times a day
both Linux NFS clients report:

Feb  6 13:16:32 lx kernel: nfs: server aix not responding, timed out
Feb  6 16:18:17 lx kernel: nfs: server aix not responding, timed out
Feb  7 04:13:08 lx kernel: nfs: server aix not responding, timed out
Feb  7 07:19:59 lx kernel: nfs: server aix not responding, timed out

Otherwise, there are no problems reported.  No errors on the
network i/f either.  The third NFS client is an AIX box and it has
been running flawless for a few years.  It seems like the load on
the network at the time when error occurs is not particularly
high.

The NFS is v3 over UDP with options soft,rsize=8192,wsize=8192.
The NFS server is AIX and it's running the Oracle RDBMS.  The
three NFS clients are running SAP apps.  The network is Gb
ethernet and there are no network errors.  AIX is 4.3.3 and Linux
kernel is 2.4.20-ac2.

Cheers!

Dejan


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
