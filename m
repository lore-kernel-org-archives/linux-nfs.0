From: trond.myklebust@fys.uio.no
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 14:40:44 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32952.207.214.87.84.1077802844.squirrel@webmail.uio.no>
References: <Pine.LNX.4.44.0402261415410.24606-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Olaf Kirch" <okir@suse.de>,"Greg Banks" <gnb@melbourne.sgi.com>,
     "ShantanuGoel" <sgoel01@yahoo.com>,nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwLmz-0006Gf-VH
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 05:42:57 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AwLlA-0005EJ-6U
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 05:41:04 -0800
To: "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0402261415410.24606-100000@kenzo.iwr.uni-heidelberg.de>
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

På to , 26/02/2004 klokka 05:20, skreiv Bogdan Costescu:
> > How do you avoid the inverse problem that async tasks end up never making
> > any progress?
>
> How about having a ratio (that can be changed from userland) between
sync and async
> operations ? Let's say that you move 3 sync ops at the head of the queue
then let 1
> async one go through. However, for this to be done efficiently it's
probably better to not
> have only one queue but more and then take one or more ops from the head
of each
> queue corresponding to the ratio.

I'm not convinced that is flexible enough. Imagine that the machine needs
to flush out some writes in order to reclaim memory for use by other
tasks. Is it then correct to be letting through a bunch of stat() requests
in order to satisfy some "ls" command instead of the memory reclaim?

To simply assert that "async" is somehow equivalent to "not important" is
just plain wrong.

Cheers,
  Trond



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
