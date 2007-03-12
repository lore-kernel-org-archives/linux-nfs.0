From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS server hangs when user hits hard quota
Date: Mon, 12 Mar 2007 12:49:39 -0400
Message-ID: <1173718179.6436.22.camel@heimdal.trondhjem.org>
References: <20070307140143.GA20450@lotka.biologie.hu-berlin.de>
	<20070312091632.GA9603@lotka.biologie.hu-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tiziano Zito <t.zito@biologie.hu-berlin.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQniX-0005pl-1a
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 09:49:51 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19j08rLvNE/WLfNSu90quOZYcKX5PrdfbY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HQniU-0000OB-Oc
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 09:49:49 -0700
In-Reply-To: <20070312091632.GA9603@lotka.biologie.hu-berlin.de>
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

On Mon, 2007-03-12 at 10:16 +0100, Tiziano Zito wrote:
> Hi all! from the lack of response I have to conclude that this is
> *our* problem and not nfs'. I've tried installing a new server but
> the problem remains. Really no one else has experienced such problems?
> I found a patch against kernel 2.4.4 (May 7, 2001) by the Linux NFS
> Client Performance Project
> http://www.citi.umich.edu/projects/nfs-perf/patches/nfs-write-tuning1.diff
> which removes the checks for hitting hard and soft limits when
> writing. The patch appears to be integrated in the code base,
> because grepping through the linux/fs/nfs source for 'hard limit'
> only yields lines in pagelist.c. I don't know NFS internals enough
> to say if this may be the cause of our problem. 
> 
> No one about this?
> 
> Thank you!
> 
> tiziano

The 2.4.x kernels are frozen. Only security fixes will be applied at
this point.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
