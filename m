From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Fri, 14 Jan 2005 13:29:42 +1100
Message-ID: <16871.11926.507904.373575@cse.unsw.edu.au>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
	<20030727163124.GC19877@perlsupport.com>
	<16164.29864.268358.781865@gargle.gargle.HOWL>
	<Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpHDn-00055P-Du
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 18:29:55 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CpHDk-0003PS-P9
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 18:29:55 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: message from Ara.T.Howard on Thursday January 13
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

On Thursday January 13, Ara.T.Howard@noaa.gov wrote:
> 
> i am seeing problems here on my system (which has rebooted and now has stale
> locks on server)
> 
..
>    server:
> 
>      mussel:~ > rpcinfo -u bligh status
>      rpcinfo: RPC: Port mapper failure - RPC: Unable to receive
>      program 100024 is not available
...
> 
>    client:
> 
>      bligh:~ > rpcinfo -p
>         program vers proto   port
>          100000    2   tcp    111  portmapper
>          100000    2   udp    111  portmapper
>          100024    1   udp  32768  status
>          100024    1   tcp  32768  status
...


So bligh, the client, is running statd (the "status" service), but
mussel can not talk to it.  This is a problem.

It would appear that some for of firewall is blocking access to
bligh's statd from mussel, or that  bligh's statd is ignoring requests
from mussel.  I don't know which.

NeilBrown


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
