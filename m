From: Eri Mendz <jerimed@myrealbox.com>
Subject: NFS dilemma: only one-sided file sharing
Date: Wed, 17 Nov 2004 08:18:26 +0300
Message-ID: <419ADF22.1000506@myrealbox.com>
Reply-To: erimendz@fastmail.fm
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CUICy-000246-C2
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 21:18:20 -0800
Received: from [192.108.102.207] (helo=smtp2-send.myrealbox.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CUICw-0001Nm-TI
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 21:18:20 -0800
To: nfs@lists.sourceforge.net
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

Hello group,

My problem is exactly as stated: NFS is working one-way only. I can put
files in the server and client can access it but readonly. Doing the 
other way around i cannot do, i get permission denied anytime i transfer 
file[s] to the server mount share. Here is my setup:

NFS server:
Slackware 10

# /etc/exports
# 192.168.0.3 is MEPIS box
/nfs    192.168.0.3(rw,anonuid=1000,anongid=100)

# /etc/hosts.allow
portmap :       192.168.0.3
lockd   :       192.168.0.3
mountd  :       192.168.0.3
rquotad :       192.168.0.3
statd   :       192.168.0.3

# /etc/hosts.deny
portmap:ALL
lockd:ALL
mountd:ALL
rquotad:ALL
statd:ALL

NFS client:
MEPIS 2004.01

# /etc/fstab
# nfs entry
alpha:/nfs /mepisNFS nfs hard,rw,rsize=8192,wsize=8192,timeo=14,intr 0 0

My target is to transfer my config files from client to server. Also i 
dont know why the files in server mount share is readonly whereas i set 
it rw in /etc/exports file.

rpcinfo -p of client:

    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100021    1   udp  32768  nlockmgr
     100021    3   udp  32768  nlockmgr
     100021    4   udp  32768  nlockmgr
     100021    1   tcp  32768  nlockmgr
     100021    3   tcp  32768  nlockmgr
     100021    4   tcp  32768  nlockmgr
     100024    1   udp    962  status
     100024    1   tcp    965  status

And for the server:

    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    920  rquotad
     100011    2   udp    920  rquotad
     100011    1   tcp    923  rquotad
     100011    2   tcp    923  rquotad
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100021    1   udp   1026  nlockmgr
     100021    3   udp   1026  nlockmgr
     100021    4   udp   1026  nlockmgr
     100005    1   udp    932  mountd
     100005    1   tcp    935  mountd
     100005    2   udp    932  mountd
     100005    2   tcp    935  mountd
     100005    3   udp    932  mountd
     100005    3   tcp    935  mountd
     100024    1   udp    938  status
     100024    1   tcp    941  status

I dont know if nfs-utils client-side got something to do with the 
problem for i cant find it in mepis box. This is my first time setting 
up NFS and clueless where to go next. I appreciate any help you good 
people can provide. TIA.

-- 
Regards,
erimendz ** use firefox/thunderbird **
http://www.spreadfirefox.com/?q=affiliates&amp;id=6670&amp;t=58



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
