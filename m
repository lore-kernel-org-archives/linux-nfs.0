From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: [Bridge] Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Mon, 17 Apr 2006 19:17:27 +0100 (BST)
Message-ID: <20060417181727.43038.qmail@web52902.mail.yahoo.com>
References: <4443D7C2.7030901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, bridge@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVYI2-0008Se-Du
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 11:17:34 -0700
Received: from web52902.mail.yahoo.com ([206.190.49.12])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FVYI1-0001kQ-Nw
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 11:17:34 -0700
To: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <4443D7C2.7030901@trash.net>
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

--- Patrick McHardy <kaber@trash.net> wrote:
> I only saw half of this thread (Chris' mails haven't made it to the lis=
t
> yet), but in case you're using bridge-netfilter and conntrack, its most
> likely because of conntrack fragmentation changes in 2.6.16. Conntrack
> defragments packets, but relies on the IP layer to do the
> refragmentation now. With purely bridged traffic, the packets don't go
> through the IP layer, so they exceed the MTU of the outgoing bridge
> port. 2.6.16.6 will include a fix for this problem:
>=20
> [patch 06/22] NETFILTER: Fix fragmentation issues with bridge netfilter

I emailed the packet dumps to Stephen privately, but what was happening w=
as that the server was
receiving the request and was fragmenting the reply.  However, the client=
 was never receiving the
reply packets for some reason.

Yes, I am using connection tracking and netfilter, and the br0 interface =
is referenced in my
iptables rules. I am not using / have not loaded the ebtables modules, al=
though I did compile
them.

Cheers,
Chris



=09
=09
	=09
___________________________________________________________=20
Yahoo! Messenger - NEW crystal clear PC to PC calling worldwide with voic=
email http://uk.messenger.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
