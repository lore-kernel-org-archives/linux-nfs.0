From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.22 NFS client vs. 2.2.19 - bigger nfs lookup rate, worse perf ormance
Date: 14 Dec 2003 17:46:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswu8zxbk3.fsf@guts.uio.no>
References: <3B372C82CD4B084D9B2B7BF2283FC6FD10E356@foxtrot.onet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVf0S-0005Ym-Nr
	for nfs@lists.sourceforge.net; Sun, 14 Dec 2003 14:46:32 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVf0S-0004OF-B1
	for nfs@lists.sourceforge.net; Sun, 14 Dec 2003 14:46:32 -0800
To: Marek Kowal <marek.kowal@portal.onet.pl>
In-Reply-To: <3B372C82CD4B084D9B2B7BF2283FC6FD10E356@foxtrot.onet>
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


You are mixing a 100Mbit and 1Gbit net and are using UDP with timeo
fixed at a pretty high value. Yes that will tend to cause slowdowns.
I suggest you go for TCP with the default value timeo=60 instead.

As for the increase in number of LOOKUPs. Most of that is due to the
close-to-open changes that were necessary for correctness.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
