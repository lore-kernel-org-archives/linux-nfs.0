From: Douglas Furlong <douglas.furlong@firebox.com>
Subject: NFS server not responding
Date: Thu, 27 Nov 2003 12:00:22 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1069934421.4677.77.camel@wibbit.firebox.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APKpo-00082f-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 04:01:24 -0800
Received: from dsl-217-155-91-196.zen.co.uk ([217.155.91.196] helo=helium.firebox.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1APKpo-0002wm-3e
	for nfs@lists.sourceforge.net; Thu, 27 Nov 2003 04:01:24 -0800
Received: from localhost (helium.firebox.com [127.0.0.1])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hARBs39e029840
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 11:54:03 GMT
Received: from helium.firebox.com ([127.0.0.1])
 by localhost (helium.firebox.com [127.0.0.1]) (amavisd-new, port 10024)
 with LMTP id 29413-02-2 for <nfs@lists.sourceforge.net>;
 Thu, 27 Nov 2003 11:54:02 +0000 (GMT)
Received: from [192.168.0.150] (wibbit.firebox.com [192.168.0.150])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hARBr4Uh029803
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 11:53:06 GMT
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

Good day all.

I am running in to excessive amounts of NFS errors as below.

kernel: nfs: server neon not responding, still trying
kernel: nfs: server neon OK

I was hoping that some of you may be able to provide me with some
assistance.

First The Hardware
------------------
Neon: FileServer
Disks: 4xSATA connected to a HighPoint RAID controller. I am using their
drivers but using Linux software raid (md0). this stores the bulk of the
data.
	1xATA connected to on-board IDE, this has the rest of the OS on it.
Network Card: 3c905 (more details can be obtained if needed).
OS: Redhat9 + all current updates + statd version 1.0.6 (from sf.net)
Authentication/User Details: Via an OpenLDAP server
Memory: 512MB
CPU: XP2800

Wibbit: Workstation
Disks: Normal ATA disk.
Network Card: 3c905 I believe.
OS: Fedora Core1 (was previously RedHat9 suffering the same problems)
Authentication/User Details: Via an OpenLDAP server
Memory: 512MB
CPU: XP2200

Network: Switched 10/100. Fileserver connected to a HP switch,
workstations connected to the HP switch via smaller 5port switches.


The Software
------------

Server
------
A bit more about the software.

The server is using an LDAP server (on the same physical network,
separate IP network) to authenticate uses credentials. nscd is running
and working on this machine.
I have exported several directory structures including home drives from
this machine.

/etc/exports
/mnt/raid/ISO/          192.168.0.1/255.255.255.0(ro,sync)
/mnt/raid/home          192.168.0.1/255.255.255.0(rw,sync)
/mnt/raid/Operations    192.168.0.1/255.255.255.0(rw,sync)
/mnt/raid/Systems       192.168.0.1/255.255.255.0(rw,sync)
/mnt/raid/CustomerServices      192.168.0.1/255.255.255.0(rw,sync)
/mnt/raid/cvs           192.168.0.1/255.255.255.0(rw,sync)
/opt    192.168.0.1/255.255.255.0(rw,sync)
# For testing using iozone
/mnt/raid/test          192.168.0.150(rw,sync,no_root_squash)

I have upgraded the version of statd due to a problem reported on a
newsgroup referring to a problem with RedHat's patches. I am not sure if
it was causing the problem, but I was (am) running out of idea's. The
patch was with regards to statd dropping root privileges.

Clients
-------
All of my testing is being done from my client, however I have about 16
Linux desktops with their home directories mounted off of Neon, and
numerous applications that are mounted off of Neon (oh plus the data).

/etc/fstab
# NFS Mounts
neon:/mnt/raid/home     /home                   nfs    
wsize=8192,rsize=8192,intr,hard 0 0
neon:/mnt/raid/ISO/     /mnt/neon/iso           nfs    
wsize=8192,rsize=8192,intr,hard 0 0 
neon:/opt               /opt                    nfs    
wsize=8192,rsize=8192,intr,hard 0 0

# NFS Mount for testing
neon:/mnt/raid/test     /mnt/neon/test          nfs    
rw,hard,intr,rsize=8192,wsize=8192 0 0

I have started nfslock on both the clients and server, as well as nfs.

Usability
---------
When my users are working on their Linux machines, they notice from time
to time that they get intermittent "freezing" where applications stop
responding, unable to switch desktops or error messages from evolution
saying it cant store data. 
All of these freezes co-inside with error messages like the below
appearing in the /var/log/messages
kernel: nfs: server neon not responding, still trying
kernel: nfs: server neon OK
The above can be repeated hundreds of times over the course of several
hours.

I had attempted to set up a network install of open office, but this
caused the machines to become 100% unusable due to OpenOffice tying up
the system. Setting the mount option to soft, prevented this, however
OpenOffice was not usable (would not start).

However I am able to run Pheonix and aMSN off of the NFS server, but I
do find at times that there is a delay opening/closing the browser. I
believe this is once again down to NFS time outs.

Below is a cat of the nfsd file in /proc/net/rpc, I am not sure what the
th value should be, but I think those numbers are quite high.

[root@neon rpc]# cat nfsd 
rc 70031 9018069 27954571
fh 10717 36541222 0 278580 494554
io 3860485896 4234117935
th 32 73218 6754.760 3694.770 2485.590 1861.300 1778.710 906.570 689.360
588.490 494.790 5316.810
ra 64 4680995 22399 14758 7499 4804 4549 2906 2844 2000 2174 306976
net 37042672 37042672 0 0
rpc 37042671 1 1 0 0
proc2 18 2 330 0 0 244 0 1306091 0 0 0 0 0 0 0 0 0 17 25
proc3 22 2 16164612 257385 4123444 1202703 5040 3745880 7412118 526581
2427 5126 108 398040 2342 350136 133820 68430 20129 37392 11528 0
1268719

Does any one have any hints or suggestions that I could take away and
work with?

Cheers

doug



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
