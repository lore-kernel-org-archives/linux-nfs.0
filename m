From: Richard Fifarek <richard.fifarek@noaa.gov>
Subject: Re: installing nfs on rh8.0 using iptables...
Date: Fri, 02 Jul 2004 13:15:00 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1088795699.8180.9.camel@rfifarek.cdc.noaa.gov>
References: <034001c46060$15045970$0301a8c0@Mesa.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BgTVa-0001qK-To
	for nfs@lists.sourceforge.net; Fri, 02 Jul 2004 12:15:38 -0700
Received: from go.cdc.noaa.gov ([140.172.156.23] helo=rfifarek.cdc.noaa.gov)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BgTVa-0001TZ-K9
	for nfs@lists.sourceforge.net; Fri, 02 Jul 2004 12:15:38 -0700
Received: from rfifarek.cdc.noaa.gov (rfifarek.cdc.noaa.gov [127.0.0.1])
	by rfifarek.cdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i62JF0mH011295
	for <nfs@lists.sourceforge.net>; Fri, 2 Jul 2004 13:15:00 -0600
Received: (from rfifarek@localhost)
	by rfifarek.cdc.noaa.gov (8.12.11/8.12.11/Submit) id i62JF0hb011294
	for nfs@lists.sourceforge.net; Fri, 2 Jul 2004 13:15:00 -0600
To: nfs@lists.sourceforge.net
In-Reply-To: <034001c46060$15045970$0301a8c0@Mesa.com>
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

On Fri, 2004-07-02 at 12:12, bruce wrote:

> (ok... but how do i find the process that starts the statd process. is this
> the /etc/rc.d/init.d/nfs script?????? )

	I can't speak to the firewalling NFS issue (it theoretically should
work), but /etc/rc.d/init.d/nfslock is the rc script that starts statd:

[rfifarek@rfifarek rfifarek]$ grep statd /etc/rc.d/init.d/*
/etc/rc.d/init.d/nfslock:[ -x /sbin/rpc.statd ] || exit 0
/etc/rc.d/init.d/nfslock:       echo -n $"Starting NFS statd: "
/etc/rc.d/init.d/nfslock:       # See if a statd's ports has been
defined
/etc/rc.d/init.d/nfslock:       daemon rpc.statd "$STATDARG"
/etc/rc.d/init.d/nfslock:       echo -n $"Stopping NFS statd: "
/etc/rc.d/init.d/nfslock:       killproc rpc.statd
/etc/rc.d/init.d/nfslock:       status rpc.statd
/etc/rc.d/init.d/nfslock:       /sbin/pidof rpc.statd >/dev/null 2>&1;
STATD="$?

-- 
Richard Fifarek <richard.fifarek@noaa.gov>
NOAA Climate Diagnostics Center


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
