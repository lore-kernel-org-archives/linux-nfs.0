From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cache/mmap()/server coherency problems
Date: Tue, 14 Jan 2003 19:57:50 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15908.23982.576007.602177@charged.uio.no>
References: <shsfzrv20h2.fsf@charged.uio.no>
	<Pine.LNX.4.44.0301140904490.9310-100000@nacho.alt.net>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YWG7-0004QI-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 10:58:00 -0800
To: Chris Caputo <ccaputo@alt.net>
In-Reply-To: <Pine.LNX.4.44.0301140904490.9310-100000@nacho.alt.net>
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

>>>>> " " == Chris Caputo <ccaputo@alt.net> writes:

     > I may not have been clear.  The issue isn't with simultaneous
     > access.

That's irrelevant. Both data and metadata (file attributes) are
*cached*.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
