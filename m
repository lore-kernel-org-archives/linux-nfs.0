From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Debian Bug#203077: Locks not released on NFS client
	reboot
Date: Thu, 20 Jan 2005 19:52:18 -0500
Message-ID: <1106268738.30991.11.camel@lade.trondhjem.org>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
	 <20030727163124.GC19877@perlsupport.com>
	 <16164.29864.268358.781865@gargle.gargle.HOWL>
	 <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
	 <16871.11926.507904.373575@cse.unsw.edu.au>
	 <Pine.LNX.4.60.0501201709220.5142@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net,
	Mark O Sleeper <Mark.O.Sleeper@noaa.gov>, thomas.r.carey@noaa.gov
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Crn2X-0003dj-1o
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 16:52:41 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Crn2W-0004Do-GR
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 16:52:40 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0501201709220.5142@harp.ngdc.noaa.gov>
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

to den 20.01.2005 Klokka 17:24 (-0700) skreiv Ara.T.Howard:

>    server iptables:
> 
>      *filter
>      :INPUT ACCEPT [0:0]
>      :FORWARD ACCEPT [0:0]
>      :OUTPUT ACCEPT [0:0]
>      -N NFS
>      -N ICMP
>      -A INPUT -i lo -j ACCEPT
>      -A INPUT -p icmp --icmp-type any -j ICMP
>      -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
>      -A INPUT -m state --state NEW -p tcp -m tcp --dport 22 -j SSH
>      -A INPUT -m state --state NEW -p udp -m udp -j NFS
>      -A INPUT -m state --state NEW -p tcp -m tcp --dport 2049 -j NFS
>      -A INPUT -m state --state NEW -p tcp -m tcp --dport 111 -j NFS
>      -A INPUT -m state --state NEW,INVALID -j REJECT --reject-with icmp-host-prohibited
>      -A INPUT -j REJECT --reject-with icmp-host-prohibited
>      -A ICMP -s 0/0 -j ACCEPT
>      -A ICMP -j REJECT --reject-with icmp-host-prohibited
>      -A NFS -s 10.1.0.0/16 -j ACCEPT
>      -A NFS -j REJECT --reject-with icmp-host-prohibited
>      -A SSH -s 10.1.0.0/16 -j ACCEPT
>      -A SSH -j REJECT --reject-with icmp-host-prohibited
>      COMMIT

Where is the rule to accept incoming rpc.statd connections?

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
