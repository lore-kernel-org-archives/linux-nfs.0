From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2 feature requests for lockd
Date: 13 Jun 2002 23:04:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr8jaj3ew.fsf@charged.uio.no>
References: <20020612162643.F10338@hermes.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Ibmf-0007rI-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Jun 2002 14:05:33 -0700
To: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
In-Reply-To: <20020612162643.F10338@hermes.centre-cired.fr>
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

>>>>> " " == Patrice DUMAS <dumas@centre-cired.fr> writes:

     > 1) client side:
     > have a nlm_prog or lockprog as option for mount, which says
     > which rpc program number to use with lockd.

     > 2) server side:
     > Monitor the caller_name instead of the rpc peer.

     > These 2 thinks are needed by sec_rpc (at least I think so) to
     > have lockd tunneling with more than one server, and working
     > statd.

I disagree totally. They are merely workarounds in order to try to
shoehorn NFS into a model for tunnelling that doesn't fit the bill...

Tunnelling should be done by setting up a proper virtual
point-to-point interface. That would do the job without needing any of
these hacks.

Cheers,
  Trond

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
