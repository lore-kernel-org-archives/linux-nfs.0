From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: NFS client does not report accurate mtime when mtime is 0
Date: Mon, 14 Jun 2004 11:57:21 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200406141657.i5EGvL812308@rda07.lmcg.wisc.edu>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BZum3-0006AV-NP
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 09:57:31 -0700
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BZum3-00050n-8W
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 09:57:31 -0700
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

I am wondering if this is a known bug and what Linux versions are
affected by it.  Or if it might be a Red Hat only bug.

I am using utimes() to set the atime/mtime of a file to 0 (i.e. the
start of the Epoch).

When I stat this file on the server and on most of my NFS clients the
atime/mtime are 0, but on some of the clients the atime is reported as
0 and the mtime is some other random time (sometimes the current time,
sometimes a time within the last few hours, but sometimes a time that
is years ago).  Here is a sample of incorrect times (run at ~11:41):

    Mon Jun 14 11:40:52 2004 ***
    Wed Jun  9 23:50:00 2004
    Tue Jun 17 09:46:31 2003
    Mon Jun 25 03:14:47 2001
    Mon Jun 14 11:41:11 2004 ***
    Mon Jun 14 10:51:48 2004
    Mon Jun 14 10:33:23 2004
    Mon Jun 14 10:10:00 2004
    Mon Jun 14 10:52:11 2004
    Mon Jun 14 11:23:57 2004
    Mon Jun 14 11:41:15 2004 ***
    Mon Jun 14 11:12:52 2004
    Thu Apr 11 09:25:14 2002
    Sat Jun 12 19:38:43 2004
    Mon Jun 14 09:49:52 2004
    Mon Jun 14 11:31:21 2004

(The "***" indicates when the mtime equaled the current time.)

Some of these times persist between repeated tests, but they all seem
to change eventually.

Everything is fine when the atime/mtime is 1 (i.e. one second after
the start of the Epoch).

The clients that report correctly are:

    2.4.9-13smp
    2.4.9-31
    2.4.9-34

The clients that report incorrectly are:

    2.4.20-13.7
    2.4.20-13.7smp
    2.4.20-28.7
    2.4.20-29.7.progeny.3

The server is running 2.4.20-29.7.progeny.4.

These are all "Red Hat Linux release 7.2 (Enigma)" releases.

Any insight would be appreciated.

-- 
Daniel K. Forrest	Laboratory for Molecular and
forrest@lmcg.wisc.edu	Computational Genomics
			University of Wisconsin, Madison


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
