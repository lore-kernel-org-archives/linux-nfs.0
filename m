From: Ian Kent <raven@themaw.net>
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Thu, 8 Jan 2004 08:32:24 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0401080830080.9294-100000@wombat.indigo.net.au>
References: <200401071817.i07IHTC20135@supercomputer.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeO6B-0006l5-IB
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 16:32:31 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AeO6A-0000pj-T1
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 16:32:31 -0800
To: <dwight@supercomputer.org>
In-Reply-To: <200401071817.i07IHTC20135@supercomputer.org>
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

On Wed, 7 Jan 2004 dwight@supercomputer.org wrote:

>
> Doing just reads (dd of the 2.4.23 kernel source .tgz, which is about 35 MB),
> it takes about 3-4 seconds. That's UDP, with a dd blocksize to match the
> NFS r/w size of 8k, on a 100 Mbs network. So this matches your results.
> This is for a Linux client talking to either a Linux or a Solaris server.

Umm. I use 32k and TCP.




-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
