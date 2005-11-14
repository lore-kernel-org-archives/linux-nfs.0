From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Diskless boot problems
Date: Mon, 14 Nov 2005 10:57:17 -0500
Message-ID: <1131983837.8870.30.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0511141441390.11652@xpc20.ast.cam.ac.uk>
	 <1131982323.8870.22.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0511141537400.11652@xpc20.ast.cam.ac.uk>
	 <1131983320.8870.28.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0511141553380.11652@xpc20.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EbgiG-0004Sl-OE
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 07:57:44 -0800
Received: from pat.uio.no ([129.240.130.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EbgiG-0006XR-DM
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 07:57:45 -0800
To: Jeremy Sanders <jss@ast.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.64.0511141553380.11652@xpc20.ast.cam.ac.uk>
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

On Mon, 2005-11-14 at 15:54 +0000, Jeremy Sanders wrote:
> On Mon, 14 Nov 2005, Trond Myklebust wrote:
> 
> > On Mon, 2005-11-14 at 15:40 +0000, Jeremy Sanders wrote:
> >
> >> I think it dies - but unfortunately I stupidly rebooted the system this
> >> time. I may have to wait a week to confirm this.
> >>
> >> I tried restarting the portmapper, but this didn't solve the problem.
> >
> > No. Restarting the portmapper isn't sufficient because you will still
> > lose all the information that the old session held. If this sort of
> > crash happens very often, you could try using pmap_dump to save the
> > portmapper information at regular intervals, then use pmap_set to
> > restore it after a crash.
> 
> Is there any way to debug it next time it crashes? I suppose the problem 
> is that unless I monitor all the traffic, I won't be able to work out how 
> it crashed.
> 

Portmap should normally send all its output to the syslogger, but if you
want extra debugging info, there is a '-v' flag that sets it in verbose
mode.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
