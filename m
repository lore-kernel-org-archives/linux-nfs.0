From: dwight@supercomputer.org
Subject: RE: Linux client on Solaris 7 NFS server
Date: Mon, 29 Dec 2003 22:17:38 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200312300617.hBU6Hc804516@supercomputer.org>
Reply-To: dwight@supercomputer.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AbCNR-0005pw-Bq
	for nfs@lists.sourceforge.net; Mon, 29 Dec 2003 21:25:09 -0800
Received: from supercomputer.org ([69.17.34.169] helo=mail.supercomputer.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AbCNR-0001pw-0H
	for nfs@lists.sourceforge.net; Mon, 29 Dec 2003 21:25:09 -0800
Received: (from watcher@localhost)
	by mail.supercomputer.org (8.11.6/8.11.6) id hBU4Gc300300
	for <nfs@lists.sourceforge.net>; Mon, 29 Dec 2003 20:16:38 -0800 (PST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On 2003-12-24 15:12, Wade Hampton wrote:
>
>  I have a Fedora Core 1.0 client connecting to a
>  Solaris X86 Version 7 NFS server.  The Solaris server
>  has locked up several times since I started accessing
>  it from Linux (this is the only change to the Solaris
>  system's environment).  I was wondering if this
>  was an NFS problem on Solaris 7 or could be a
>  hardware problem with the NIC.
>  ...

If the Solaris Server is locking up, this is a problem with
Solaris. It might be somehow triggered by Linux, but that is
absolutely no excuse for a server problem. The server should
just stay up.

Sun has some excellent resources available for making certain 
your system is up-to-date. Go over sun.com, and start with the 
support link. They have this patch manager tool which will 
examine your system, figure out what patches it needs, and 
apply them. I don't recall if you need a support contract to
use it or not.

One of the other nice tools they have is their search of their
bugs database system. Here's one which may be related:

#57406: "NFS Server May Panic Upon Receipt of Certain Invalid
Client Requests" Oct 27, 2003.

That's a bad sign. They do list a number of patches for the
issue.

"Sensitive" should refer to performance. My experience is that
Linux NFS clients exhibit horrible performance issues with Sun
servers in standard, out-of-the-box configurations. That's in
comparison to using pure Sun or pure Linux Server/Client
combinations.

        -dwight-




-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
