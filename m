From: Olaf Kirch <okir@suse.de>
Subject: xprt_bindresvport
Date: Wed, 8 Dec 2004 09:58:48 +0100
Message-ID: <20041208085848.GB12215@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cbxey-0003bk-RR
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 00:58:56 -0800
Received: from mail.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1Cbxex-00073q-1S
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 00:58:56 -0800
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id D96C511E347A
	for <nfs@lists.sourceforge.net>; Wed,  8 Dec 2004 09:58:48 +0100 (CET)
To: nfs@lists.sourceforge.net
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

Hi,

the current xprt_bindresvport implementation will search for a privileged
port by counting down from 800 to 0. I think this is a bug, because it
will potentially interfere with services trying to bind to low ports as
well. The bindresvport implementation in glibc picks from the 600-1023
range.

I also think it would be good to start at a "random" port. Otherwise,
when you reboot, the server may still have a TCB for the old connection
and send you an ACK probe when you try to connect (if all goes well), and
the client's TCP stack will RST and fail the connect. If things go
not-so-well you have a packet filter somewhere inbetween that eats the
ACK probe because its connection tracking engine thinks the connection
is in half-open and shouldn't see any SYN-less ACKs yet.

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
