From: Peter Astrand <peter@cendio.se>
Subject: Re: userspace NFS daemon
Date: Mon, 6 Sep 2004 21:43:08 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0409062139180.18897-100000@maggie.lkpg.cendio.se>
References: <20040906191343.GA859@janus>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4POY-0007gk-L3
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 12:43:18 -0700
Received: from cheddar.cendio.se ([193.12.253.77] helo=mail.cendio.se)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C4POS-0005LS-EU
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 12:43:15 -0700
To: Frank van Maarseveen <frankvm@xs4all.nl>
In-Reply-To: <20040906191343.GA859@janus>
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

> > * Can run the MOUNT and NFS protocol on the same TCP port. Very useful 
> > when tunneling through SSH. 
> 
> Suppose I have an ssh tunnel to a system on which I don't have root
> access. Can I use unfs3 under a non-root id there to export / and
> below, mount it [as root] locally, such, that I can work under my own
> uid locally?

Yes, that works. 

-- 
Peter Åstrand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Linköping        Phone: +46-13-21 46 00





-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
