From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 9 Dec 2004 14:44:41 +0100
Message-ID: <20041209134441.GB11998@suse.de>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com> <41B74551.5040908@sun.com> <20041209113107.GE15055@suse.de> <1102599415.24133.34.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Waychison <Michael.Waychison@sun.com>,
	Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcOb8-0006Gk-4z
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 05:44:46 -0800
Received: from mail-ex.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CcOb6-0007F3-LE
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 05:44:46 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1102599415.24133.34.camel@lade.trondhjem.org>
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

On Thu, Dec 09, 2004 at 08:36:55AM -0500, Trond Myklebust wrote:
> > Shouldn't we allow NFS mounts to use non-privileged ports? Many
> > environments don't really care about the "security" provided by privileged
> > ports, but would be more than happy if they can run with a few hundred
> > NFS mounts
> 
> Most AUTH_SYS based models still require it, however I agree that use of
> strong security makes the privileged port totally redundant.

The Linux auth_sys works fine with unprivileged ports if you allow it to;
so why shouldn't we make that configurable on the client too? It'd sure
help some  installations who for some reason or other habe an excessive
number of exported file systems (see .sig below :).

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
