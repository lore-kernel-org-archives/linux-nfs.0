From: Erik Walthinsen <omega@pdxcolo.net>
Subject: Re: Converting open filehandles to pathnames
Date: Sun, 09 May 2004 14:11:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084137085.715.26.camel@omikron>
References: <1084059203.714.13.camel@omikron>
	 <20040509072418.GB18762@sgi.com> <1084063428.714.40.camel@omikron>
	 <1084148814.29382.32.camel@binkley>  <20040510030029.GL30964@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BN2Rz-0003dy-7S
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 21:31:35 -0700
Received: from [216.99.212.251] (helo=mail.omegacs.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BN2Ry-0003c2-S9
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 21:31:34 -0700
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20040510030029.GL30964@polop.usc.edu>
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

On Sun, 2004-05-09 at 20:00, Garrick Staples wrote:
> > Any thoughts to making this program available anywhere? I'd be
> > interested to get some mappings to find out who my most abusive users
> > are.
> Come to think of it, I've found myself in the same situation... wondering who
> is beating up my NFS servers.  This would be a great tool to have.

Sure.  In its current incarnation it's a Python script using a pcap
module I found in some package that I can no longer identify....  It's
also quite tied to my current file structure, though some of that also
has to do with the earlier assumptions I made about filehandles.

The biggest challenge for general usage is the inode -> pathname
translation.  In my case there are currently about 900 files I can look
up before the packet capture starts, and cache those inode numbers.  A
general utility will require a different solution, starting with the
existing method of snooping getattr and other calls.  Any other
suggestions on how I can generically convert inodes to pathnames without
massive overhead?

Once I have my current code doing what I want I'll clean it up and post
it here so it can be hacked into a useful tool.



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
