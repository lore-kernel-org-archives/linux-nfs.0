From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: NFS reliability in Enterprise Environment
Date: Thu, 2 Feb 2006 08:41:24 -0600
Message-ID: <EXCHG2003ZKpjE5aHaZ00001176@EXCHG2003.microtech-ks.com>
References: <5573EF758F632B43A91FE1A01B6AC3D401B77D6B@exch3-dc-aus.northamerica.corporate-domain.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4fs5-0002OT-Mp
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 06:55:41 -0800
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F4fs0-0002Cr-Al
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 06:55:38 -0800
To: "'David Sullivan'" <david.sullivan@activant.com>,
	<nfs@lists.sourceforge.net>
In-Reply-To: <5573EF758F632B43A91FE1A01B6AC3D401B77D6B@exch3-dc-aus.northamerica.corporate-domain.net>
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

 

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of David Sullivan
> Sent: Wednesday, February 01, 2006 4:02 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS reliability in Enterprise Environment
> 
> Does anyone have any data they can share on the reliability 
> of Linux NFS servers (not clients) in an enterprise 
> environment (e.g. server uptimes, number of volumes shared, 
> number of clients, IO rates)?  I have a large enterprise 
> application set (about 10K programs) that uses NFS for 
> file-sharing.  A movement is afoot at my company to port the 
> applications from the more expensive "big iron" Unix systems 
> it is currently deployed on to less expensive Linux x86 
> servers.  I'm trying to do a baseline risk assessment of this 
> move, and I'd like some empirical data (or some speculative) 
> on the reliability of NFS.  Even better would be a contrast 
> in reliability to shared-storage filesystems like GFS or OCFS2.
>  
> TIA!

Just to note, since usually the underlying disk is the 
bottleneck, having 2 servers hit the same disk hardware does
not really help.

If you want things to scale, I would find a way to logically
separate things.

On the speed note, with cheap arrays and cheap NFS servers (basic
dual cpu machines) I can serve single stream writes at 
95MByte/second, and reads at 115MByte/second, both of these are
sustained rates (10x+ times the amount of possible cache anywhere
in the setup), and this is over a single ethernet, to a single
14 disk array.

I would personally stay away from the shared filesystems, the
trade off required to make them share between machines probably
cut the speed enough to make it not worth it.

With single arrays (such as the above mentioned test), the total
rate gets lower when two machines (or two streams from the same
machine) access the same array (physical disks) as the disks 
start to seek around.

When I last did it, I broke things up into small physical units and
spread them over many cheap machines (1-2TB, this was to allow
us to get very large IO rates, ie 500MBytes/second+, and this was
3+ years ago), this also allow us to have a fully tested cold 
spare that could replace any broken server machine
within 1 hour.    This was a better thing over the large Suns we
had previously as we only had 2 of them, and really could not afford
to keep a 100k machine as a cold spare.

                            Roger



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
