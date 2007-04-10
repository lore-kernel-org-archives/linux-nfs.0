From: Olaf Kirch <okir@lst.de>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Tue, 10 Apr 2007 11:09:43 +0200
Message-ID: <200704101109.44333.okir@lst.de>
References: <46156FA0.4030506@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1410463973=="
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbCMo-0000Kj-6r
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 02:10:23 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbCMN-0007Dj-3p
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 02:09:56 -0700
In-Reply-To: <46156FA0.4030506@redhat.com>
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

This is a multi-part message in MIME format...

--===============1410463973==
Content-Type: multipart/alternative; boundary="Boundary-00=_YR1GGhG0q1G7VQ4"

This is a multi-part message in MIME format...

--Boundary-00=_YR1GGhG0q1G7VQ4
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 05 April 2007 23:52, Wendy Cheng wrote:
> The changes record the ip interface that accepts the lock requests and 
> passes the correct "my_name" (in standard IPV4 dot notation) to user 
> mode statd (instead of system_utsname.nodename). This enables rpc.statd 
> to add the correct taken-over IPv4 address into the 3rd parameter of 
> ha_callout program. Current nfs-utils always resets "my_name" into 
> loopback address (127.0.0.1), regardless the statement made in rpc.statd 
> man page. Check out "man rpc.statd" and "man sm-notify" for details.

I don't think this is the right approach. For one, there's not enough
room in the SM_MON request to accomodate an additional IPv6
address, so you would have to come up with something entirely
different for IPv6 anyway. But more importantly, I think we should
move away from associating all sorts of network level addresses
with lockd state - addresses are just smoke and mirrors. Despite
all of NLM/NSMs shortcomings, there's a vehicle to convey identity,
and that's mon_name. IMHO the focus should be on making it work
properly if it doesn't do what you do.

But - why do you need to record the address on which the request was
received. at all? Don't you know beforehand on which IP addresses you
will be servicing NFS requests, and which will need to be migrated?

Side note: should we think about replacing SM_MON with some new
design altogether (think netlink)?

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--Boundary-00=_YR1GGhG0q1G7VQ4--


--===============1410463973==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1410463973==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1410463973==--
