From: "Paul Cunningham" <paulcunningham@sprintmail.com>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 17:07:56 -0500
Message-ID: <030901c4d0df$b9664bf0$2801a8c0@PAULLAPTOP1>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com> <20041122153655.GH1291@suse.de>  <41A2280B.1010005@int-evry.fr> <1101146906.11196.35.camel@lade.trondhjem.org> <41A236A6.4050104@int-evry.fr> <1101154485.11196.64.camel@lade.trondhjem.org> <02f401c4d0d6$ce19e9c0$2801a8c0@PAULLAPTOP1> <1101158068.11196.71.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWMMn-0007SB-Vt
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:09:01 -0800
Received: from pop-a065d05.pas.sa.earthlink.net ([207.217.121.249])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWMMi-0000Qi-3Q
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:09:01 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Sorry, I must have missed the export option in a previous message. As I 
shake the cobwebs, I cannot remember an async export option used to increase 
performance with a warning from the man page "allows the NFS server to 
violate  the  NFS  protocol".

Sounds like a dangerous option.  Perhaps I'm too far removed from this now, 
but the applicable mount options were async and v3.  The server then should 
adhere to the mount request from the client regardless of an export option. 
This all assumes v3 is available on the server.  Scanning the man page on my 
various Linux boxes I cannot find a v3 mount option, the issue is becoming 
much clearer now!

So how does a client mount NFS v3 with Linux?

Paul Cunningham


----- Original Message ----- 
From: "Trond Myklebust" <trond.myklebust@fys.uio.no>
To: "Paul Cunningham" <paulcunningham@sprintmail.com>
Cc: <nfs@lists.sourceforge.net>
Sent: Monday, November 22, 2004 4:14 PM
Subject: Re: [NFS] async vs. sync


må den 22.11.2004 Klokka 16:04 (-0500) skreiv Paul Cunningham:

> It has been a few years, but I remember some of the async details.  I
> always
> used async for performance reasons, and much testing was performed to
> assure
> no data would be lost.  If a client sent an async write to the server,
> the
> call could return prior to data being flushed to disk.  The data would
> make
> it to disk once the server decided to write it or the client sends in
> a
> COMMIT.  At some point in time the client will attempt to close the
> file,
> this is when a COMMIT must be sent, the hope is that the server has
> already
> written the dirty pages to disk while the client was busy doing other
> things, and will respond with an OK quickly.  If any dirty pages
> remain,
> they must be flushed prior to responding OK.  Data should never be
> lost as
> long as the NFSPROC3_COMMIT procedure is adhered to.
>

Sure. This is how the Linux client works. The problem is the "async"
*export* option on the server.

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
