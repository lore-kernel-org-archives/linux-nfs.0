From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: File monitoring
Date: Sun, 28 Jan 2007 17:49:11 -0500
Message-ID: <20070128224911.GA18039@ti64.telemetry-investments.com>
References: <Pine.LNX.4.61.0701272123470.22295@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBIps-0002Om-Ks
	for nfs@lists.sourceforge.net; Sun, 28 Jan 2007 14:49:20 -0800
Received: from gw1a.telemetry-investments.com ([64.20.161.180]
	helo=sv1.telemetry-investments.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBIpt-00014A-Dr
	for nfs@lists.sourceforge.net; Sun, 28 Jan 2007 14:49:22 -0800
In-Reply-To: <Pine.LNX.4.61.0701272123470.22295@yvahk01.tjqt.qr>
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

On Sat, Jan 27, 2007 at 09:31:42PM +0100, Jan Engelhardt wrote:
> as part of implementing a netboot solution, I observe that the client 
> pulls about 128 MB of data (measured in iptraf, so it includes 
> IPv4 headers too). You probably agree that this contributes to a boot 
> that could possibly be sped up (even if the same distribution was to 
> read from local disk). I wonder what files it actually accesses. Is 
> there some utility to get a listing of all the files that were accessed? 
> tcpdump provides a nice hint, e.g.
 
For testing, try using UNFS3 ( http://unfs3.sourceforge.net ), a userspace
NFSv3 server implementation, rather than the in-kernel knfsd server.  It should
be a simple matter to hack up the server code to log the client file accesses.

Regards,

	Bill Rugolsky

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
