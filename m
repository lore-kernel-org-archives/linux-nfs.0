From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Help needed
Date: Wed, 04 May 2005 08:35:10 -0400
Message-ID: <1115210110.10831.10.camel@lade.trondhjem.org>
References: <200505041206.20407.benjamin@benjamin76.plus.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTJ68-0001IA-Rj
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 05:35:28 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DTJ67-0000yh-3t
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 05:35:28 -0700
To: benjamin@benjamin76.plus.com
In-Reply-To: <200505041206.20407.benjamin@benjamin76.plus.com>
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

on den 04.05.2005 Klokka 12:06 (+0100) skreiv Benjamin Jeeves:
> Hi all
> 
> This is the first time posting to this list so please understand if this 
> quistion has been posted before.
> 
> I have one server with 4 ethernet card in all running on 192.168.1.* network 
> what i want to do is run nfs on.
> 
> eth2 192.168.1.6 running nfs
> eth3 192.168.1.7 running nfs
> 
> eth2 would export samething like this /backup then /store.
> 
> eth3 would export samething like this /folder3 /folder4
> 
> but at this time all I can do is make it work on all of the ethernet cards and 
> only work on the first ethernet card eth0 for all requests.
> 
> I have search gooogle and man pages but can not find anything or would I need 
> to do load balancing for this to work?
> 
> I have tryed this in the /etc/exports file:
> 192.168.1.6:/backup	192.168.1.12(rw,root_squash,sync)
> 192.168.1.6:/store	192.168.1.12(rw,root_squash,sync)
> 192.168.1.7:/folder3	192.168.1.14(rw,root_squash,sync)
> 192.168.1.7:/folder4	192.168.1.14(rw,root_squash,sync)

That sort of syntax is definitely not supported. NFS shouldn't have to
know or care about how you want to organise your network.

If you want to enforce no NFS traffic on eth0, then how about using
iptables to block traffic to port 2049 on that interface?

You might then add static routes to 192.168.1.12 and 192.168.1.14 and/or
set up iptables rules on the server if you want to enforce which
interface those machines are allowed to talk to.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
