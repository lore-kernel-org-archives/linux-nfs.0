From: Paul Heinlein <heinlein@cse.ogi.edu>
Subject: iostat wkB/s numbers during testing
Date: Fri, 14 Feb 2003 07:32:20 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302140716060.20965-100000@glenfiddich.cse.ogi.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from franklin.cse.ogi.edu ([129.95.40.9])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jhpC-0003ou-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 07:32:26 -0800
Received: from euclid.cse.ogi.edu (euclid.cse.ogi.edu [129.95.41.95])
	by franklin.cse.ogi.edu (8.12.6/8.12.6) with ESMTP id h1EFWKC5021527
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 07:32:20 -0800 (PST)
Received: from glenfiddich.cse.ogi.edu (glenfiddich.cse.ogi.edu [129.95.33.101])
	(authenticated bits=0)
	by euclid.cse.ogi.edu (8.12.5/8.12.5) with ESMTP id h1EFWKNP015352
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 07:32:20 -0800
To: nfs@lists.sourceforge.net
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

I'm using a dual P-III Compaq DL380 running Red Hat 8.0 to host a new
ATABoy RAID array purchased from Nexsan. It's connected to our switch
via a gig/fiber card based on the Intel 82542 chipset.

The service stack (for lack of a better phrase) is

* ATABoy2 -- six-drive RAID-5 array that presents itself to the host 
             as a single SCSI device (no multiple LUNs)
* LVM     -- 1.0.3, one PV, one VG, one LV (so far :-)
* XFS     -- 1.2pre5
* NFS     -- v2/v3, UDP only, 80 nfsd threads
* Samba   -- 2.2.7

Last night, I set up six NFS clients and one Linux/smbfs client to run 
iozone against the nfs mount/samba share.

I was keeping track of stats using iostat -x on the server. My typical
wkB/s numbers hovered in the 15000 to 19000 range. Is that sort of
result set consistent with what any of you have seen for Linux-hosted 
NFS RAID exports?

--Paul Heinlein <heinlein@cse.ogi.edu>



-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
