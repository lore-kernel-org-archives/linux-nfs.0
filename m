From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Fri, 26 Sep 2003 15:29:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16244.48596.850187.268449@charged.uio.no>
References: <16243.34641.819894.763746@charged.uio.no>
	<200309261831.h8QIVNVw026806@buggy.badula.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A31cZ-0003g9-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 16:03:31 -0700
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A31cY-0006TQ-FK
	for nfs@lists.sourceforge.net; Fri, 26 Sep 2003 16:03:30 -0700
Received: from pat.uio.no ([129.240.130.16]:50945)
	by externalmx.vasoftware.com with esmtp (Exim 4.22 #1 (Debian))
	id 1A316V-0008Ko-LV
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 15:30:23 -0700
To: Ion Badulescu <lists@news.cs.columbia.edu>
In-Reply-To: <200309261831.h8QIVNVw026806@buggy.badula.org>
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

>>>>> " " == Ion Badulescu <lists@news.cs.columbia.edu> writes:

     > Ugh, that's ugly -- and potentially a DoS issue as well. Since
     > you don't need any privileges to issue the 'kill -9' for your
     > own processes, it becomes fairly easy to write some code that
     > exploits this and causes kernel crashes across the board...

Then don't set the "intr" flag.

     > Not that the current situation is any better, of course.

     > Perhaps making that wait an uninterruptable wait would be
     > enough to take care of the problem?

People expect the "intr" flag to work if they set it.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
