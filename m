From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Fri, 21 Jan 2005 11:59:17 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501211157450.15036@harp.ngdc.noaa.gov>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
 <20030727163124.GC19877@perlsupport.com>  <16164.29864.268358.781865@gargle.gargle.HOWL>
  <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
 <16871.11926.507904.373575@cse.unsw.edu.au>  <Pine.LNX.4.60.0501201709220.5142@harp.ngdc.noaa.gov>
  <1106268738.30991.11.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0501211118380.15036@harp.ngdc.noaa.gov>
 <1106332841.21404.253.camel@localhost.localdomain>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@cse.unsw.edu.au>, Chip Salzenberg <chip@pobox.com>,
	nfs@lists.sourceforge.net, Mark O Sleeper <Mark.O.Sleeper@noaa.gov>,
	thomas.r.carey@noaa.gov
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs40C-0005qf-IJ
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 10:59:24 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cs40C-0005PO-5g
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 10:59:24 -0800
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1106332841.21404.253.camel@localhost.localdomain>
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

On Fri, 21 Jan 2005, Dan Stromberg wrote:

>
> A sniffer is your friend.  ethereal is the best I've encountered.
>
> If you fire up an ethereal to sniff packets from your client on the server,
> and/or vice versa, you will likely get an idea of what's wrong fairly
> quickly.

probably the next step.

> BTW, last I heard, NFS on linux could be firewalled, but it required
> starting up some daemons with some magic options to hard code them to
> specific ports, rather than allowing portmap/rpcbind to move them around.


unless i am mistaken, by adding

>>    on the server - where ip is the client's ip
>>
>>      -A INPUT -s 10.1.186.71/32 -j ACCEPT
>>
>>    on the client, where ip is the server's ip
>>
>>      -A INPUT -s 10.1.186.54/32 -j ACCEPT

we effictively did NOT firewall ANYTHING between client and server so
portmapping shouldn't have made any difference right?

cheers.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
