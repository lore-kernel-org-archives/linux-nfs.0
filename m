From: dwight@supercomputer.org
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Wed, 07 Jan 2004 10:17:29 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401071817.i07IHTC20135@supercomputer.org>
References: <raven@themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeIFV-0005dY-2z
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 10:17:45 -0800
Received: from supercomputer.org ([69.17.34.169] helo=mail.supercomputer.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AeIFU-0005m8-Lc
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 10:17:44 -0800
To: Ian Kent <raven@themaw.net>
In-Reply-To: Message from Ian Kent <raven@themaw.net>
   of "Tue, 06 Jan 2004 12:42:17 +0800." <Pine.LNX.4.33.0401061229170.26529-100000@wombat.indigo.net.au>
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

Thanks for the suggestion, Ian. It was a good one, and I've carried it a
little farther.

First, this is all single threaded at the user level. It's a mixture of
reads and writes; akin to a large compile (actually link) of a bunch of
files, creating one big binary. Just using a local disk, we're looking at
about 3-4 secs. Over NFS, it's 30 seconds, except for the Linux client case.

Doing just reads (dd of the 2.4.23 kernel source .tgz, which is about 35 MB),
it takes about 3-4 seconds. That's UDP, with a dd blocksize to match the
NFS r/w size of 8k, on a 100 Mbs network. So this matches your results.
This is for a Linux client talking to either a Linux or a Solaris server.

However, doing a write, I see different results. In the Linux/Linux case,
again the result is again about 3-4 seconds. However, with a Linux-client/
Solaris-server, it takes about 12 seconds. This is a factor of 3-4.

I'm wondering if the mixture of reads and writes is what is driving the
degradation up to a factor of 6.

I'll give the pure Solaris/Solaris results a try. Anecdotally, I've heard
that there are also similar issues with HP-UX and AIX, though I haven't
tried it out myself.

Best Regards,

	-dwight-


Ian Kent wrote:

> I had some figures, but I've deleted them.
> 
> Basically I'm saying, with a 100Mb(it)/sec interface I get just over
> 8 MB(ytes)/sec whereas I can consistently get over 10MB(ytes)/sec on most
> Sparcs (Solaris). So the Sparcs are pushing their interfaces about fast as
> they can go but the Linux box is not. So there's still room for
> improvement.





-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
