From: Tom McNeal <trmcneal@attbi.com>
Subject: NFS utils package, and an fsx question
Date: Sun, 12 May 2002 19:27:06 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CDF247A.E7106AA4@attbi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc54.attbi.com ([216.148.227.87])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1775WG-0006bt-00
	for <nfs@lists.sourceforge.net>; Sun, 12 May 2002 19:25:00 -0700
Received: from attbi.com ([12.234.31.73]) by rwcrmhc54.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with ESMTP
          id <20020513022454.TCWT25765.rwcrmhc54.attbi.com@attbi.com>
          for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 02:24:55 +0000
To: NFS maillist <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi -

I've created and tested a new NFS utils package, which can be
downloaded from 

http://nfs.sourceforge.net/nfs-utils-1-0-1-pre7.tar.gz

The tests consist of the 4 2002 Connectathon tests suites
(basic, general, special, and lock), fsx, a duplicate request
cache exerciser, and bonnie++, all running simultaneously
overnight.  I tested a 2.4.18 and 2.2.19  UP client against
2.4 and 2.2 UP servers.  The failure rate was less than 1%,
primarily due to interaction between special and general tests 
that I haven't quite figured out yet.

I see nothing in the utils package that tells me it isn't ready
for prime time.  I'd really like to see someone with MP platforms 
pick this up and test it, but other than that, I think its ready
to rename as release 1.0.1. BTW, I don't know the history of release
1.0.0; It was already 1.0.1-prex when I started working on it.

I have a couple of questions about fsx behavior:

 - It appears that with memory mapping allowed, fsx doesn't 
allow more than 12 operations running per test, regardless of 
the kernel; is this fixed with a later version of fsx, or maybe
I just have my system misconfigured?  My version of fsx is about
6  months old, and I didn't look at configuration at all.

 - In 2.2 kernels, the failure rate climbs significantly 
unless I cut the number of operations per test in half; once
I turned off memory mapping, I ran with 5000 ops in the 2.4 
kernel, but had to run about 2500 ops in the 2.2 client kernel
to get the same failure rate (~1%).  Is this a suprise?

Tom

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
