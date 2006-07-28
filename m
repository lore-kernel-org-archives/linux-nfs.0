From: "Michael Han" <mhan@postini.com>
Subject: Re: default sunrpc.min_resvport
Date: Fri, 28 Jul 2006 10:58:36 -0700
Message-ID: <168996D6C4DFA945B032B63C0DEAA6BF0421EA7D@EXCHANGE1.postini.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6Wbr-0006E9-7l
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 10:58:51 -0700
Received: from exprod8og54.obsmtp.com ([64.18.3.90])
	by mail.sourceforge.net with smtp (TLSv1:AES256-SHA:256) (Exim 4.44)
	id 1G6Wbi-0004jJ-AL
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 10:58:43 -0700
To: "Chuck Lever" <chucklever@gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

>From Chuck Lever:
> "For the record," some sites have a requirement for a larger 
> port space.

Naturally they do. auto-home systems with thousands of users could
easily cause this. I'm just pointing out that I'm satisfied with my own
workaround.
 
> The daemon actually wouldn't show up on the security scan.  The
> hardware IPMI listener would, however.  The daemon is not visible on
> the network because the IPMI listener diverts packets to that port.

Of course, you are correct. That's the crux of the problem I
encountered. Silly me.

> Other workarounds worth mentioning: disable IPMI in the hardware, or
> don't use the built-in NIC for NFS traffic.

Yes. Another possible alternative is to divert IPMI traffic to an
IPMI-only address. I'm not certain this works, but I know the SuperMicro
BMCs support use of alternate MAC & IP. I just don't know if the port
623/664 intercepts are promiscuous. I tried changing this on a hot
system to no avail, but not after rebooting a system and all that good
stuff.

> Indeed.  I'm not familiar enough with IPMI to know if it listens on
> both the UDP and the TCP port.

I believe that in all implementations, IPMI only uses UDP
conventionally, however the port allocation from IANA is for both
transports and it appears that more than one implementation intercepts
both transports (I've seen this issue referenced on systems using Intel
NICs with IPMI support and on Sun x86 hardware). I'm pretty uneducated
as far as IPMI goes, myself.

-- 
Michael Han






-----------------------------------------------------------
This message may contain confidential and/or privileged 
information. This information is intended to be read only
by the individual or entity to whom it is addressed. If
you are not the intended recipient, you are on notice that
any review, disclosure, copying, distribution or use of
the contents of this message is strictly prohibited. If
you have received this message in error, please notify the
sender immediately and delete or destroy any copy of this
message.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
