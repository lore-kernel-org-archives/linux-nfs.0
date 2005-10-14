From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS security
Date: Fri, 14 Oct 2005 11:52:23 -0400
Message-ID: <1129305143.8571.46.camel@lade.trondhjem.org>
References: <f872993a0510130004p90cb2eal3dd17d58b892083d@mail.gmail.com>
	 <1129207423.8578.3.camel@lade.trondhjem.org>
	 <f872993a0510140741l1ac0147ep1c6fea89b737434c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQRrW-0002VV-Ke
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 08:52:50 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EQRrV-0006Pi-Dr
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 08:52:50 -0700
To: Raghu R <roverphoenix@gmail.com>
In-Reply-To: <f872993a0510140741l1ac0147ep1c6fea89b737434c@mail.gmail.com>
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

fr den 14.10.2005 Klokka 07:41 (-0700) skreiv Raghu R:
> Hi,
> 
> I am sorry I mistyped that I had meant GSS-API and not GAA-API, I
> actually proposed to the professor today he says the scope of the
> project is huge for a single person for a perid of abt 2 months, the
> professor has suggested something simpler managable like a fix or
> something tp add to security to NFS, can you suggest some?

I'm not sure I understand you. We already have GSS-API support for Linux
NFS on both client and server in linux-2.6.x. RPCSEC_GSS _is_ GSS-API
for SunRPC based protocols.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
