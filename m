From: "randy" <paries@knology.net>
Subject: server local.flanders not responding, still trying on console
Date: Sun, 29 Aug 2004 02:29:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C1K7k-0007dv-U5@sc8-sf-mx1.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1K7o-0004ip-DP
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 00:29:16 -0700
Received: from smtp.knology.net ([24.214.63.101])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1C1K7k-0007dv-U5
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 00:29:16 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: 
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
 
I have two rh9 boxes. One is the NFS server and one is the client.
 
They are very busy web servers that share the same document root via nfs. 
 
i keep getting these errors on my console and in my message file May  3
12:44:11 krusty kernel: nfs: server local.flanders not responding, still
trying May  3 12:44:15 krusty kernel: nfs: server local.flanders OK

these two boxes each have a GIGaBit ethernet card and a crossover cable
connecting each other and it is only used for NFS.

All other network functions use the other nics

Stats are below, I am currently running 49 nfsd's

Thanks for any suggestions

On the server
nfsstat -s
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
25718710   0          0          0          0       
Server nfs v2:
null       getattr    setattr    root       lookup     readlink   
4      100% 0       0% 0       0% 0       0% 0       0% 0       0% 
read       wrcache    write      create     remove     rename     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
link       symlink    mkdir      rmdir      readdir    fsstat     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 

Server nfs v3:
null       getattr    setattr    lookup     access     readlink   
4       0% 10236002 39% 42905   0% 5439928 21% 8598    0% 60099   0% 
read       write      create     mkdir      symlink    mknod      
8919197 34% 910196  3% 21816   0% 106     0% 330     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
2634    0% 26      0% 5288    0% 0       0% 12840   0% 0       0% 
fsstat     fsinfo     pathconf   commit     
24      0% 24      0% 0       0% 58689   0% 


On the Client
nfsstat -c
Client rpc stats:
calls      retrans    authrefrsh
24616865   131061     0       
Client nfs v2:
null       getattr    setattr    root       lookup     readlink   
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
read       wrcache    write      create     remove     rename     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
link       symlink    mkdir      rmdir      readdir    fsstat     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 

Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 10174261 41% 20990   0% 5363659 21% 7342    0% 59652   0% 
read       write      create     mkdir      symlink    mknod      
8811537 35% 119194  0% 6475    0% 53      0% 315     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1900    0% 26      0% 4712    0% 0       0% 12658   0% 0       0% 
fsstat     fsinfo     pathconf   commit     
11      0% 11      0% 0       0% 34069   0% 




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
