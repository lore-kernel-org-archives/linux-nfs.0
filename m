From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: userspace NFS daemon
Date: Mon, 6 Sep 2004 21:13:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040906191343.GA859@janus>
References: <20040905220120.GA29596@janus> <Pine.LNX.4.44.0409060935290.20425-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4Ovz-0001Xr-Ui
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 12:13:47 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C4Ovx-0000dp-Kg
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 12:13:46 -0700
To: Peter Astrand <peter@cendio.se>
In-Reply-To: <Pine.LNX.4.44.0409060935290.20425-100000@maggie.lkpg.cendio.se>
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

On Mon, Sep 06, 2004 at 09:41:31AM +0200, Peter Astrand wrote:
> 
> Another alternative is unfs3: http://unfs3.sourceforge.net/. It provides 
> the same cluster extensions, and also has some other interesting features:
> ...
> * Can run the MOUNT and NFS protocol on the same TCP port. Very useful 
> when tunneling through SSH. 

Suppose I have an ssh tunnel to a system on which I don't have root
access. Can I use unfs3 under a non-root id there to export / and
below, mount it [as root] locally, such, that I can work under my own
uid locally?

That would be quite useful.

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
