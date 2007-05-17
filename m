From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 0/14] A transport switch for knfsd
Date: Thu, 17 May 2007 08:11:49 -0400
Message-ID: <EXNANE01mWzAKbn0wkU00000a24@exnane01.hq.netapp.com>
References: <20070516191821.GF9626@sgi.com>
	<20070516205316.GC18927@fieldses.org>
	<20070517070004.GC27247@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hoept-0005gL-Ia
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 05:12:01 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hoept-0004mn-BB
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 05:12:04 -0700
In-Reply-To: <20070517070004.GC27247@sgi.com>
References: <20070516191821.GF9626@sgi.com>
	<20070516205316.GC18927@fieldses.org>
	<20070517070004.GC27247@sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 03:00 AM 5/17/2007, Greg Banks wrote:
>It's intertesting to note that ipv6 support was added without a
>serverside transport switch; on Irix the addition of ipv6 was what
>justified a transport switch.

At the moment, the client-side support doesn't use it either, though it
did in earlier experiments. Right now it seems that simply passing in a
AF_INET6 address is sufficient to trigger its use.

I think the key thing about a "transport" in the NFS context is that it's
really a "transport API", i.e. it uses sockets, or RDMA, or has some special
property that requires special interface handling.

For example, while SCTP in its basic single-stream mode uses sockets and
might be a relatively close match to TCP, there are a lot of other aspects
to the protocol which are nothing like it and won't be visible pretending it's
just TCP (e.g. associations, integrity, etc). Having a bottom-edge transport
abstraction helps a lot in taking advantage of them.

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
