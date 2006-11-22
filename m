From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "mount: File exists" when trying to mount a second
	krb5	volume!
Date: Wed, 22 Nov 2006 15:43:13 -0500
Message-ID: <1164228193.5694.38.camel@lade.trondhjem.org>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmywS-0001XX-Sx
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 12:43:37 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19ucAFUD0AP6zaRuWjxugok1bRddCpiIe8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GmywR-0002vo-UV
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 12:43:38 -0800
To: Open Source <opensource3141@yahoo.com>
In-Reply-To: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
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

On Mon, 2006-11-20 at 11:47 -0800, Open Source wrote:
> Hi Trond,
> 
> I can confirm that I also see a crash with your patch file in place!
> I'm not sure if that's because it didn't apply cleanly to begin with
> and my massaging might have caused a problem.  I don't think
> so though.
> 
> Basically if you mount a couple NFSv3+krb5 partitions and
> then unmount one of them, the system locks up after about 2
> seconds.  I didn't see this before since I didn't use the
> automounter utility.

I'm unable to reproduce whether using the automounter or not. Can you be
a bit more specific about what hangs? Are you seeing an Oops or anything
like that?

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
