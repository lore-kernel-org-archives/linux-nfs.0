From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: 2 feature requests for lockd
Date: Fri, 14 Jun 2002 14:05:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020614140522.D3312@hermes.centre-cired.fr>
References: <20020612162643.F10338@hermes.centre-cired.fr> <shsr8jaj3ew.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Ipqp-0000CP-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Jun 2002 05:06:47 -0700
Received: from hermes.centre-cired.fr ([193.51.120.92])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id OAA00790
          for <nfs@lists.sourceforge.net>; Fri, 14 Jun 2002 14:04:45 +0100 (WEST)
Received: (from dumas@localhost)
	by hermes.centre-cired.fr (8.11.6/8.11.6) id g5EC5MU04009
	for nfs@lists.sourceforge.net; Fri, 14 Jun 2002 14:05:22 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shsr8jaj3ew.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Thu, Jun 13, 2002 at 11:04:55PM +0200
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

Hi,

> I disagree totally. They are merely workarounds in order to try to
> shoehorn NFS into a model for tunnelling that doesn't fit the bill...

Indeed.

> Tunnelling should be done by setting up a proper virtual
> point-to-point interface. That would do the job without needing any of
> these hacks.

I agree again, but the point in tunneling rpc based services through
ssh like with sec_rpc, is that it is quite easy to set up, almost off the box. 
Maybe there exists point-to-point solutions as easy to set up but I don't 
know them.

Pat

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
