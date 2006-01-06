From: Stephen Carville <stephen@totalflood.com>
Subject: NFS performance tuning
Date: Fri, 06 Jan 2006 08:45:55 -0800
Message-ID: <43BE9EC3.3090108@totalflood.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Euuj3-0005Jm-2L
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 08:46:01 -0800
Received: from [209.189.103.195] (helo=mail.totalflood.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Euuiy-0005e7-LK
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 08:45:59 -0800
Received: from [192.168.124.232] (pellucidar.totalflood.com [192.168.124.232])
	by mail.totalflood.com (Un-Exchange Mail Version 9.7.2.4) with ESMTP id 6BFCD5409A
	for <nfs@lists.sourceforge.net>; Fri,  6 Jan 2006 08:45:55 -0800 (PST)
To: NFS List <nfs@lists.sourceforge.net>
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

I have NFS server running on a Dell 2850:

   Name: Amazon
    CPU: 3000 Mhz Xeon  (X2)
Memory: 2G
   Swap: 8G
     OS: Fedora Core 3
    NFS: Version 1-4

I export a 150G volume thusly:

/NFS/tigris_backup
10.1.1.0/24(rw,wdelay,nohide,insecure,root_squash,no_subtree_check,anonuid=65534,anongid=65534)

The client is a Dell 2650 running Oracle 9i

   Name: Tigris
    CPU: 3200Mhz Xeon (X2)
Memory: 8G
   Swap: 4G
     OS: Redhat ES 3.2
    NFS: Version 2/tcp

Both have hyperthreading enabled.
The machines are connected via a dedicated gigabit switch.

The goal (among others) is to run the nightly RMAN backups of the Oracle
database to the NFS drive on Amazon where it is backed up to tape later.
To this end I mount the NFS volume, run the backups, and unmount the volme.

That part works well.  However the thruput on the connection is much
less than I expected.  Simple file transfers for example give only about:

Using NFS
Amazon to Tigris: 168 Mbps
Tigris to Amazon: 104 Mbps

Using ftp
ssh A to T: 320 Mbps
ssh T to A  360 Mbps

I can accept that I may never get a full Gigabit per second over copper
but it still looks like there is room for improvement in the NFS trnsfer
speeds.

Suggestions?

-- 
Stephen Carville <stephen@totalflood.com>
Unix and Network Admin
Nationwide Totalflood
6033 W. Century Blvd
Los Angeles, CA 90045
310-342-3602



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
