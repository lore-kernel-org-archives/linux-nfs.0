From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 010 of 11] knfsd: make pools numa aware
Date: Wed, 26 Jul 2006 12:20:42 +1000
Message-ID: <1153880442.21040.206.camel@hole.melbourne.sgi.com>
References: <1153804618.21040.25.camel@hole.melbourne.sgi.com>
	<1153831393.5660.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5Z5r-0000LO-V2
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 19:25:52 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5Z5p-0001fM-43
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 19:25:52 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1G5Z18-0003KE-P4
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 19:21:00 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1153831393.5660.13.camel@localhost>
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

On Tue, 2006-07-25 at 22:43, Trond Myklebust wrote:
> On Tue, 2006-07-25 at 15:16 +1000, Greg Banks wrote:
> > +		m->mode = 0;	/* default: one global pool */
> > +#ifdef CONFIG_NUMA
>    ^^^^^^^^^^^^^^^^^^ Growl...
> 
> Perhaps a helper function to hide the ifdef.

I believe Neil has since cured the worst of my #ifdef disease.

> > +		m->mode = 0;
> > +		m->npools = 1;
> > +		printk("nfsd: initialising 1 global pool\n");
>                           ^^^^ ho hum....
> 
> Please keep sunrpc and nfsd separate.

Sorry, my bad.

>  Also, this should probably be a
> dprintk() in order to avoid spamming the syslogs.

I don't see how that would be helpful.  This message happens
when the first nfsd thread is started.  On a system where sunrpc
and nfsd are modular, there's a very small time window between
loading the sunrpc module and starting the first nfsd thread.
So there would be little opportunity to set the debug flag to
enable the dprintk() to appear.  Would you be happy with just
removing the printk() entirely?

> > +
> > +#if SVC_HAVE_MULTIPLE_POOLS
> 
> ^^^^^^^^^^^^ Any reason why you've done this? A definition shouldn't be
> that worrying to us...

When you put it like that, no good reason at all.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
