From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH] Access cache forgetting mode bits
Date: Mon, 01 Sep 2003 09:13:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F534601.7060702@RedHat.com>
References: <3F4E302F.5060409@RedHat.com>	<1062107512.2121.25.camel@bree.suse.de>	<3F525BA8.9020904@RedHat.com>	<1062372316.2341.16.camel@bree.suse.de>	<3F52BB88.2040303@RedHat.com> <16210.49805.828391.567668@charged.uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000102060402060101000408"
Cc: Andreas Gruenbacher <agruen@suse.de>, nfs@lists.sourceforge.net,
   Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19toVi-0003ZI-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Sep 2003 06:14:22 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19toVg-0000Hb-4x
	for nfs@lists.sourceforge.net; Mon, 01 Sep 2003 06:14:20 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <16210.49805.828391.567668@charged.uio.no>
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

This is a multi-part message in MIME format.
--------------000102060402060101000408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Trond,

Trond Myklebust wrote:

>What are you using to measure performance here? It would be nice to
>see some figures to demonstrate the improvement.
>  
>
Good point... If figured the Connectathon test suite (cthon03) would be good
since it has a large variety of tests and easy to run... But if there 
are other tests
that would be good just let me know...

Running cthon03 three times and using nfsstat to count the total number
of rpc and access here are the numbers...

Run 1              total calls  access calls
Original Code:   30230       1755    5%
Andreas's Patch: 30181       1676    5%
Latest Patch:       29671       1141    3%

Run 2              total calls  access calls
Original Code:   30064       1755    5%
Andreas's Patch: 30176       1676    5%
Latest Patch:       29978       1141    3%

Run 3              total calls  access calls
Original Code:   30286      1755    5%
Andreas's Patch: 29978      1676    5%
Latest Patch:       29410      1141    3%

Note: It is not a cut/paste error that each test run had the same
amount of access calls... the only number that really fluctuated
was the number of getattrs.... that's why I only ran the tests three
times... not much seem to be changing...

I've attached the raw data pruned of the v2 stats...

SteveD.




--------------000102060402060101000408
Content-Type: text/plain;
 name="orig"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="orig"

Client rpc stats:
calls      retrans    authrefrsh
30230      15         0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1587    5% 1199    3% 2428    8% 1755    5% 250     0% 
read       write      create     mkdir      symlink    mknod      
3976   13% 12304  40% 890     2% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 407     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    4% 1       0% 0       0% 573     1% 

Client rpc stats:
calls      retrans    authrefrsh
30064      28         0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1493    4% 1199    3% 2362    7% 1755    5% 250     0% 
read       write      create     mkdir      symlink    mknod      
3976   13% 12304  40% 890     2% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 404     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    4% 1       0% 0       0% 570     1% 

Client rpc stats:
calls      retrans    authrefrsh
30286      24         0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1520    5% 1199    3% 2554    8% 1755    5% 250     0% 
read       write      create     mkdir      symlink    mknod      
3976   13% 12304  40% 890     2% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 406     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    4% 1       0% 0       0% 571     1% 


--------------000102060402060101000408
Content-Type: text/plain;
 name="andreas"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="andreas"

Client rpc stats:
calls      retrans    authrefrsh
30181      24         0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1478    4% 1199    3% 2567    8% 1676    5% 250     0% 
read       write      create     mkdir      symlink    mknod      
3977   13% 12305  40% 890     2% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 405     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    4% 1       0% 0       0% 573     1% 

Client rpc stats:
calls      retrans    authrefrsh
30176      24         0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1574    5% 1199    3% 2477    8% 1676    5% 250     0% 
read       write      create     mkdir      symlink    mknod      
3976   13% 12304  40% 890     2% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 401     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    4% 1       0% 0       0% 568     1% 

Client rpc stats:
calls      retrans    authrefrsh
29978      8          0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1515    5% 1199    3% 2335    7% 1676    5% 250     0% 
read       write      create     mkdir      symlink    mknod      
3976   13% 12304  41% 890     2% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 403     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    5% 1       0% 0       0% 569     1% 


--------------000102060402060101000408
Content-Type: text/plain;
 name="latest"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="latest"

Client rpc stats:
calls      retrans    authrefrsh
29671      9          0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1644    5% 1199    4% 2432    8% 1141    3% 250     0% 
read       write      create     mkdir      symlink    mknod      
3976   13% 12304  41% 890     2% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 403     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    5% 1       0% 0       0% 571     1% 

Client rpc stats:
calls      retrans    authrefrsh
29761      10         0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1682    5% 1199    4% 2484    8% 1141    3% 250     0% 
read       write      create     mkdir      symlink    mknod      
3976   13% 12303  41% 890     2% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 405     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    5% 1       0% 0       0% 570     1% 

Client rpc stats:
calls      retrans    authrefrsh
29410      23         0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1492    5% 1199    4% 2318    7% 1141    3% 250     0% 
read       write      create     mkdir      symlink    mknod      
3976   13% 12304  41% 890     3% 175     0% 250     0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1389    4% 175     0% 403     1% 250     0% 0       0% 1121    3% 
fsstat     fsinfo     pathconf   commit     
1500    5% 1       0% 0       0% 576     1% 


--------------000102060402060101000408--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
