From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS synchronization problems on Beowulf cluster
Date: Thu, 20 Jul 2006 07:04:24 -0400
Message-ID: <1153393464.5856.12.camel@localhost>
References: <m1hd1gksev.fsf@minerva.ceride.gov.ar>
	<1153162159.13961.3.camel@localhost>
	<m1ejwjtb2t.fsf@minerva.ceride.gov.ar>
	<1153230531.22180.7.camel@localhost>
	<m1y7uopn3i.fsf@minerva.ceride.gov.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3WKm-0005ZJ-KO
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 04:04:48 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G3WKm-0007PZ-Ib
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 04:04:49 -0700
To: Mario Storti <mstorti@intec.unl.edu.ar>
In-Reply-To: <m1y7uopn3i.fsf@minerva.ceride.gov.ar>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-07-20 at 07:49 -0300, Mario Storti wrote:
> I tried to do a `ls -l' of the directory and the contents of the files
> are still out of sync. (I assume that `ls -l' does an `opendir()' call.)
> 
> Perhaps these questions are too basic for this list. In that case,
> please redirect me to the appropriated list or newsgroup. 

'ls' does an opendir(), and should normally check that the cache is up
to date. If that is not working, then something is indeed broken.

Which mount options are you seeing this with? What kind of server are
you using (if it is a Linux server, please could you specify the kernel
version and the filesystem).

Also please could you tell us if you can reproduce the problem on a more
recent kernel version (2.6.9 is several years old).

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
