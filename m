From: "Randy Paries" <paries@knology.net>
Subject: debugging help
Date: Mon, 3 May 2004 15:54:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BKkU6-00073s-7o@sc8-sf-mx1.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKkUc-0003VR-3V
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 13:56:50 -0700
Received: from smtp.knology.net ([24.214.63.101] helo=smtp2.knology.net)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BKkU6-00073s-7o
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 13:56:18 -0700
To: <nfs@lists.sourceforge.net>
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

Hello
 
I have two boxes. One is the NFS server and one is the client.
 
They are very busy web servers. 
 
i keep getting these errors on my console and in my message file
May  3 12:44:11 krusty kernel: nfs: server local.flanders not responding,
still trying
May  3 12:44:15 krusty kernel: nfs: server local.flanders OK

I am looking for suggestions on how to debug these.

I am doing many reads and writes

These are my mount strings
local.flanders:/home/unitnet  /home/unitnet  nfs
intr,rsize=8192,wsize=8192,bg  0  0
local.flanders:/home/unitnetconsult  /home/unitnetconsult  nfs
intr,rsize=8192,wsize=8192,bg 0  0

Thanks for anyhelp or direction

 
if i do a nfstats -s on the server i get 
nfsstat -s
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
28339803   0          0          0          0       
Server nfs v2:
null       getattr    setattr    root       lookup     readlink   
2      100% 0       0% 0       0% 0       0% 0       0% 0       0% 
read       wrcache    write      create     remove     rename     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
link       symlink    mkdir      rmdir      readdir    fsstat     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
 
Server nfs v3:
null       getattr    setattr    lookup     access     readlink   
1       0% 14651833 51% 33447   0% 7230784 25% 4969    0% 85667   0% 
read       write      create     mkdir      symlink    mknod      
6002057 21% 247908  0% 12344   0% 59      0% 303     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
2094    0% 22      0% 6146    0% 0       0% 13730   0% 0       0% 
fsstat     fsinfo     pathconf   commit     
76      0% 76      0% 0       0% 48285   0% 

 
and on the client
nfsstat -c   
Client rpc stats:
calls      retrans    authrefrsh
5594114    16482      0       
Client nfs v2:
null       getattr    setattr    root       lookup     readlink   
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
read       wrcache    write      create     remove     rename     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
link       symlink    mkdir      rmdir      readdir    fsstat     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
 
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 2485192 44% 8445    0% 1627026 29% 4723    0% 21922   0% 
read       write      create     mkdir      symlink    mknod      
1369595 24% 56448   1% 3251    0% 13      0% 92      0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
614     0% 3       0% 1712    0% 0       0% 3593    0% 0       0% 
fsstat     fsinfo     pathconf   commit     
20      0% 20      0% 0       0% 11445   0% 




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
