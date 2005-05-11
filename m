From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: Memory usage
Date: Tue, 10 May 2005 23:33:00 -0400
Message-ID: <1115782380.10234.125.camel@cutter>
References: <20050506161018.GA3979@infradead.org>
	 <1115410171.1960.26.camel@lade.trondhjem.org>
	 <20050510122745.GA28981@infradead.org> <42816FA8.5000606@unixgrrl.net>
	 <42817444.1040707@catfeeder.net>  <42817708.6030607@unixgrrl.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sean Dogar <sean@catfeeder.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVhxT-0006ua-5m
	for nfs@lists.sourceforge.net; Tue, 10 May 2005 20:32:27 -0700
Received: from mail.phy.duke.edu ([152.3.182.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DVhxR-0004JE-OW
	for nfs@lists.sourceforge.net; Tue, 10 May 2005 20:32:27 -0700
To: liz@unixgrrl.net
In-Reply-To: <42817708.6030607@unixgrrl.net>
Sender: nfs-admin@lists.sourceforge.net
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


> If it is indeed NFS is there a way to make it not do that :P I looked
> in my o'reilly book, googled and posted to kernel dev (WIth my
> asbestos jacket on and zipped up ;)
> 
> The machine is running 2.4.21 EL-SMP

Go to red hat's bugzilla. Read up on slab values and how to adjust your
caching. This is what's going on.
Also:
http://people.redhat.com/nhorman/papers/papers.html
read the top paper. i think it will help your problem some.

-sv




-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
