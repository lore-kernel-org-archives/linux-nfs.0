From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: gigabit, 2.4.22 and timeo
Date: Tue, 14 Oct 2003 14:31:05 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16268.16617.933560.195383@charged.uio.no>
References: <1066134271.629.19.camel@newdeal>
	<shs7k37x4rs.fsf@charged.uio.no>
	<1066148509.2582.1.camel@newdeal>
	<16268.9170.985048.378514@charged.uio.no>
	<1066150954.2582.8.camel@newdeal>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9Twy-0005jQ-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 11:31:16 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9Twu-0003aC-JJ
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 11:31:12 -0700
To: Roberto Sebastiano <robs@multiplayer.it>
In-Reply-To: <1066150954.2582.8.camel@newdeal>
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

>>>>> " " == Roberto Sebastiano <robs@multiplayer.it> writes:

     > While transferring the files it seems that "ls -laR" on the
     > other nfs client is a little slow ..

     > I'm worried that the 500-1000 apache childs will hang on reads
     > from network. Is there any way to prevent this ? Maybe more
     > nfsd instances on the server ?

Yes. Note that each NFS client will use a maximum of 16 nfsd threads
on the server at any point in time. Of course, that tails off as you
start to hit the scalability curves as you add more clients, but it is
a good rule of thumb if you just have between 1 and 8 clients...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
