From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: speed for NFS
Date: Tue, 27 Aug 2002 07:12:21 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D273@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jh59-0004m3-00
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 07:12:35 -0700
To: "'Reimar Bauer'" <r.bauer@fz-juelich.de>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

hi reimar-

> in the next few years we will have  much amount of
> data something about 70 - 100 TByte.
> 
> At the moment with our configuration nfs speed is 
> quite less against the network speed.
> I believe this could be extended and this is necessary.
> 
> The max transfer rate we have is about 3MByte/sec.
> 
> Is there a possibility to increase this to 30MByte/sec.
> Is this relalistic? 
> Where can I get a description about this? 

3MB/s is poor even for 100base-T.  as ragnar suggested,
you should test and possibly improve the local disk speed
on your servers.  you may have fast disks on your servers,
but they may not be scaling well if there are many clients
accessing them concurrently.  possibly, reorganizing your
data sets across existing spindles can improve scalability.

i also recommend that you study your current network set up.
if there are packet losses, this will adversely impact the
performance of your NFS clients.  look carefully at your
switches to be sure they are not dropping packets.  look
at "netstat -s" and "nfsstat -c" on your clients to be
certain they see a healthy network.

there is a Linux NFS FAQ at http://nfs.sourceforge.net that
has many useful ideas about how to assess and improve your
performance picture.


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
