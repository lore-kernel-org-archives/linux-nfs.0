From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: export only to special mac addresses
Date: Sun, 24 Mar 2002 01:25:54 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200203240125.54414.bernd-schubert@web.de>
References: <200203211807.g2LI74M02426@fubini.pci.uni-heidelberg.de> <20020323161512.GA10804@obelix.home.gunix.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16ovo2-0005zJ-00
	for <nfs@lists.sourceforge.net>; Sat, 23 Mar 2002 16:24:18 -0800
Received: from [145.254.212.62] (helo=bathl)
	by smtp.web.de with esmtp (WEB.DE(Exim) 4.41 #2)
	id 16ovnu-0005TL-00
	for nfs@lists.sourceforge.net; Sun, 24 Mar 2002 01:24:11 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20020323161512.GA10804@obelix.home.gunix.de>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello Alexander,

thanks for your information. This is helping me very much.

Bernd

> > Hi all,
> >
> > we are exporting a root filesystem to several clients. Since the clients
> > are allowed  to write to the filesystem, we have a bad feeling about
> > security (though we have a firewall).
> >
> > To slightly increase security we would like to allow only clients with
> > special MAC addresses to mount this fs.
> > So I'd like to know if there is already support for this.
>
> i dont know, if therfor is support from nfs directly.
> but i think, there is a arp filter module in upcominf 2.4.19
> linux-kernel.
>
> in combination with this i think it must be
> possible to realize a nfs export to spezial mac adresses.
>
> i dont tried it, because kernel is not stable yet, but ir will be in
> near future.
>
>
> mfg ag
>
> > Thanks in advance,
> >
> > Bernd
> >
> >
> >
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
