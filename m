From: Alex Thiel <stderr@web.de>
Subject: Re: huge number of intr/s on large nfs server
Date: Thu, 17 Oct 2002 13:15:47 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210171315.47213.stderr@web.de>
References: <CFEAJJEGMGECBCJFLGDBGEMACFAA.enorwood@effrem.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1828Y6-0001M6-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 04:10:42 -0700
To: "Eff Norwood" <enorwood@effrem.com>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBGEMACFAA.enorwood@effrem.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday 17 October 2002 04:49, Eff Norwood wrote:
>
> Switch is a Foundry BigIron and clients are 30 x SuperMicro SuperServer
> 6010H with dual PIII 1.0Ghz, 1024MB of RAM, and Syskonnect SK-9821 copp=
er
> gigabit cards also running Debian 3.0 Stable with kernel 2.4.19 and all=
 of
> Trond's latest NFS client patches.
>

Just to be sure: have you checked that the clients are actually only send=
ing=20
at 100Mbit/s?

=09Alex



-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
