From: Chris Penney <cpenney@gmail.com>
Subject: Re: NAT & lockd
Date: Fri, 8 Apr 2005 10:08:00 -0400
Message-ID: <111aefd050408070844511651@mail.gmail.com>
References: <111aefd050408062546161db8@mail.gmail.com>
	 <1112967554.15565.58.camel@lade.trondhjem.org>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJu9Y-0001ZO-40
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 07:08:08 -0700
Received: from wproxy.gmail.com ([64.233.184.202])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJu9X-0007t7-FP
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 07:08:07 -0700
Received: by wproxy.gmail.com with SMTP id 69so852180wra
        for <nfs@lists.sourceforge.net>; Fri, 08 Apr 2005 07:08:01 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1112967554.15565.58.camel@lade.trondhjem.org>
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

> > nsm_mon_unmon: rpc failed, status=-13
> > lockd: cannot monitor x.x.x.x
> >
> > With our old NFS server I never got any messages.  The IP address
> > x.x.x.x is that of the NAT box.  I'm curious if this means locking
> > does not work behind nat or if it means something else.  Is there
> > anything I can do here?  Would a 2.6.x based NAT box have a more up to
> > date iptables that supports lockd?  This is non-critical, I'm just
> > trying to understand.
> 
> Locking under NFSv2/v3 is not very NAT or firewall-friendly and was one
> of the motivations for developing NFSv4.
> 
> The problem is that under NFSv2/v3, the protocol requires bi-directional
> communication (by which I mean that the server needs to be able to
> connect to the client, which is a problem for NAT as you can see above)
> and requires a bunch of helper-protocols that use different ports (which
> is a problem for firewalls).

In this situation (behind NAT), what happens with the client?  Will a
lock request fail or simply appear to always work?

Do I need to be concerned about the server reliability at all (ie. are
the messages harmless other than obviously the files not really being
locked)?

Thanks for the fast reply,

   Chris


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
