From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Thu, 22 Mar 2007 08:36:12 -0400
Message-ID: <EXNANE01eDKvPEkGhAj0000029d@exnane01.hq.netapp.com>
References: <17914.20117.186786.830574@notabene.brown>
	<EXNANE01pH71yEXUIEA000000e2@exnane01.hq.netapp.com>
	<17917.50411.770610.290399@notabene.brown>
	<EXNANE016beUzmRf6Ci00000104@exnane01.hq.netapp.com>
	<17922.3087.206883.910415@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUMWh-0003kx-0a
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 05:36:19 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUMWj-00080x-5q
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 05:36:21 -0700
In-Reply-To: <17922.3087.206883.910415@notabene.brown>
References: <17914.20117.186786.830574@notabene.brown>
	<EXNANE01pH71yEXUIEA000000e2@exnane01.hq.netapp.com>
	<17917.50411.770610.290399@notabene.brown>
	<EXNANE016beUzmRf6Ci00000104@exnane01.hq.netapp.com>
	<17922.3087.206883.910415@notabene.brown>
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

At 12:54 AM 3/22/2007, Neil Brown wrote:
>If you do have multi-homed hosts you need to enable host-name matching
>(via a sysctl) and ensure that hostnames are used consistently.
>i.e. the hostname used when you mount a filesystem must be the same as
>that which sm-notify on the server will use in mon_name when sending
>notify that it has reboot.

Sort of. The server's mon_name needs to map back to the IP address that
the client mounted. It doesn't have to be literally the servername that the
client mounted, in fact the server doesn't know that. Besides there's
multihoming, dhcp, etc.

The point is: the *hostnames* are the invariant in nlm recovery.

>In the other direction, sm-notify on the NFS client must simply mon_name
>to "uname -n" as that will be the 'caller_name' in the LOCK request.

Correct.

>I guess that to be completely safe, a NOTIFY should be sent from every
>IP that the local host has, to every IP that every peer has, with
>mon_name set to the source IP address, and then again with mon_name set
>to the host name, both simple and FQDN.

Some hosts go even further, they send a dotted-quad address in another
notify. And, some machines (I won't name names) fail to handle this, because
they pass the mon_name directly to the DNS resolver library without trying
an inet_aton().

>And when you receive a NOTIFY, you should do an DNS lookup to find the
>FQDN and then all the IP addresses, and then assume a reboot for any
>local state that matches any of that.

Yes, you need to go from the provided hostname to all its IP aliases. You
can throw in the source address you got the notify from, but in theory that's
one of them. To be VERY sure, the server should send all these notifies from
each and every one of its interfaces. This ensures that the message gets
routed successfully, and also that clients who don't do the full resolve (or
see a DNS error etc) have a prayer of knowing what to do.

Even then, the server has to guess. A reply to a notify doesn't mean the
notify succeeded, because (as I mentioned in an earlier message), the notify
is a void procedure, so any statd will reply whether or not it cares. A client
that starts reclaiming is a good indication that something was reached, but
since there's no reclaim done indicator, the server has no clue that the client
is finished.

Bottom line, the server has to do everything it possibly can, and then pray.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
