From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bridge] Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Mon, 17 Apr 2006 20:00:34 +0200
Message-ID: <4443D7C2.7030901@trash.net>
References: <20060414235008.66335.qmail@web52913.mail.yahoo.com> <44408207.1070404@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chris Rankin <rankincj@yahoo.com>, nfs@lists.sourceforge.net,
	bridge@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVY1k-0006hG-N4
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 11:00:44 -0700
Received: from stinky.trash.net ([213.144.137.162])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FVY1j-0003Oh-Hb
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 11:00:44 -0700
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <44408207.1070404@osdl.org>
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

Stephen Hemminger wrote:
> Then get a packet trace of a failing session with tcpdump. You may need
> to get two, one
> one the client and one on the server to be able to see which packet
> isn't getting past the
> bridge.

I only saw half of this thread (Chris' mails haven't made it to the list
yet), but in case you're using bridge-netfilter and conntrack, its most
likely because of conntrack fragmentation changes in 2.6.16. Conntrack
defragments packets, but relies on the IP layer to do the
refragmentation now. With purely bridged traffic, the packets don't go
through the IP layer, so they exceed the MTU of the outgoing bridge
port. 2.6.16.6 will include a fix for this problem:

[patch 06/22] NETFILTER: Fix fragmentation issues with bridge netfilter


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
