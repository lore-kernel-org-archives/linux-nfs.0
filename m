From: fvm@altium.nl (Frank van Maarseveen)
Subject: Re: 2 feature requests for lockd
Date: Fri, 14 Jun 2002 17:56:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020614155632.GA4277@altium.nl>
References: <20020612162643.F10338@hermes.centre-cired.fr> <shsr8jaj3ew.fsf@charged.uio.no> <20020614140522.D3312@hermes.centre-cired.fr>
Reply-To: frank.van.maarseveen@altium.nl
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.tasking.nl ([195.193.207.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ItTu-0000KI-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Jun 2002 08:59:23 -0700
Received: (from root@localhost) by ns.tasking.nl (8.9.1a/8.6.12) id RAA04610 for <nfs@lists.sourceforge.net>; Fri, 14 Jun 2002 17:59:17 +0200 (MET DST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20020614140522.D3312@hermes.centre-cired.fr>
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

On Fri, Jun 14, 2002 at 02:05:22PM +0200, Patrice DUMAS - DOCT wrote:
> 
> I agree again, but the point in tunneling rpc based services through
> ssh like with sec_rpc, is that it is quite easy to set up, almost off the box. 
> Maybe there exists point-to-point solutions as easy to set up but I don't 
> know them.
> 

It is fairly easy to set up a PPP link over ssh using the pppd "pty"
command, provided you have root access at both ends for doing the
initial configuration. Then you have full IP connectivity. In
addition, it is possible to do routing for connecting all the networks
at both sides (I'm using something similar for years now).

-- 
Frank

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
