From: "Paul Cunningham" <paulcunningham@sprintmail.com>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 16:04:05 -0500
Message-ID: <02f401c4d0d6$ce19e9c0$2801a8c0@PAULLAPTOP1>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com> <20041122153655.GH1291@suse.de>  <41A2280B.1010005@int-evry.fr> <1101146906.11196.35.camel@lade.trondhjem.org> <41A236A6.4050104@int-evry.fr> <1101154485.11196.64.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Cc: "Olaf Kirch" <okir@suse.de>, <nfs@lists.sourceforge.net>,
	<mci-unix@int-evry.fr>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWLN4-0006gu-UT
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 13:05:14 -0800
Received: from pop-a065d05.pas.sa.earthlink.net ([207.217.121.249])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWLN0-00064Z-RM
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 13:05:14 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"jehan.procaccia" <jehan.procaccia@int-evry.fr>
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

It has been a few years, but I remember some of the async details.  I always 
used async for performance reasons, and much testing was performed to assure 
no data would be lost.  If a client sent an async write to the server, the 
call could return prior to data being flushed to disk.  The data would make 
it to disk once the server decided to write it or the client sends in a 
COMMIT.  At some point in time the client will attempt to close the file, 
this is when a COMMIT must be sent, the hope is that the server has already 
written the dirty pages to disk while the client was busy doing other 
things, and will respond with an OK quickly.  If any dirty pages remain, 
they must be flushed prior to responding OK.  Data should never be lost as 
long as the NFSPROC3_COMMIT procedure is adhered to.

This is my recollection of how NFS v3 works (former kernel programmer), not 
necessarily how Linux implements the protocol (but I hope these rules are 
followed).

Paul Cunningham

----- Original Message ----- 
From: "Trond Myklebust" <trond.myklebust@fys.uio.no>
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Cc: "Olaf Kirch" <okir@suse.de>; <nfs@lists.sourceforge.net>; 
<mci-unix@int-evry.fr>
Sent: Monday, November 22, 2004 3:14 PM
Subject: Re: [NFS] async vs. sync


må den 22.11.2004 Klokka 19:57 (+0100) skreiv jehan.procaccia:
> >
> in my old solaris 7 nfs it was async I suppose ! although we didn't lose
> data, maybe we where risking it ... ? anyway now I move from and old
> solaris NFS server to a brand new linux one with a SAN (AX100) Storage
> Processor in Raid 5 an Fiber Channel attachement, how can I support
> performances more than 50 times longer :-( with that config,  user and
> manager wil tell me that I  spoild money on that new server !, there
> must be a misconfiguration somewhere ?.
>

Solaris has no equivalent to the "async" export option. AFAIK that is a
Linux creation.

Cheers,
  Trond
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
