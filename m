From: Daniel Koch <DanielKoch@gmx.net>
Subject: Problems with mounting NFS
Date: Tue, 21 Jan 2003 17:34:35 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <7184.1043166875@www62.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx0.gmx.de ([213.165.64.100] helo=mx0.gmx.net)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18b1MJ-0001D5-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 08:34:43 -0800
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

Hi, 
 
I'm having problems with my NFS mounting at boottime. It takes about 8-10 
min to boot, and when I do dmesg I get the following message: 
 
nfs warning: mount version older than kernel 
portmap: server localhost not responding, timed out 
portmap: server localhost not responding, timed out 
lockd_up: makesock failed, error=-5 
portmap: server localhost not responding, timed out 
 
My NFS server is a Pentium II 300MHz laptop with 124 MB RAM . Operating 
system is SUSE Linux 8.0 (kernel 2.4.18) 
etc/exports: 
/home/antares 192.168.1.7(rw) 
 
My NFS client is a 586 embedded PC 100Mhz with 32 MB RAM. Operating system 
is a Whitedwarf Linux 1.2 (kernel 2.4.18-rthal5 RTAI) 
/etc/fstab: 
 
192.168.1.10:/home/antares /home/antares/NFS 	nfs	rw,hard,intr	0  
0 
 
The problems occured after switching the client`s operating system from 
Whitedwarf Linux version 1.1 (kernel 2.2.14) to version 1.2 (kernel 
above). I`m a newbie to NFS, so I do apologize if this is a faq (I didn`t 
find a solution when I read the very good NFS manual here at sourceforge). 
I'd appreciate any help. 
 
Daniel   
   

-- 
+++ GMX - Mail, Messaging & more  http://www.gmx.net +++
NEU: Mit GMX ins Internet. Rund um die Uhr für 1 ct/ Min. surfen!



-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
