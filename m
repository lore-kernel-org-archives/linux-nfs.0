From: Duc Vianney <dvianney@us.ibm.com>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 13:42:27 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF2F88E36F.887DAD35-ON85256DDD.00694D03-86256DDD.006C4237@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jason Holmes <jholmes@psu.edu>, nfs@lists.sourceforge.net,
        nfs-admin@lists.sourceforge.net, trond.myklebust@fys.uio.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKNOA-0002L4-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 11:44:22 -0800
Received: from e4.ny.us.ibm.com ([32.97.182.104])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AKNOA-0001Ae-0X
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 11:44:22 -0800
To: Eric Whiting <ewhiting@amis.com>
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


> Trond Myklebust/Jason Holmes/Eric Whiting wrote ...

I ran the iozone in the cluster mode to time read and write under NFSv3.
Under a server memory constraint scenario, I saw reads on 2.6.0-test9 about
8X slower than 2.4.22.
For writes, I saw improvement in 2.6.0-test9 irrespective of server memory
size.

The following data represents the throughput in KB/sec as seen by the NFS
server subject to various memory sizes.

   Server Memory  512MB   512MB      2048MB   2048MB
   Kernel         2.4.22  260-test9  2.4.22   260-test9
   Write          14514   29134      13670    29330
   Rewrite        15140   25943      14683    27046
   Read           24404    3685      72165    78445
   ReRead         24702    3705      73267    78375

NFS Server: 4-way 700MHz, 2.5GB RAM, e1000 switch box, stock 2.6.0-test9.
NFS Client: 2-way, 2GHz, 1GB RAM, e1000, stock kernel 2.4.22, NFSv3 mounted
with default parameters
Benchmark: iozone running in cluster mode from the server with test file
size set to 1GB.

rpc data for 2422 and 260test9 at 512MB and 2048MB server memory:

             512MB    512MB    ratio            2048MB   2048MB    ratio
Kernel        2422    260t9  2422/260t9           2422   260t9   2422/260t

Server nfs v3 stats:
getattr         3       15     0.20                 3        3     1.00
fsstat          0        0                          0        0
fsinfo          0        0                          0        0
read       262992    66409     3.96            262992    65545     4.01
write      262162    65806     3.98            262162    65646     3.99
access         20       20     1.00                20       20     1.00
remove          2        1     2.00                 2        1     2.00
create          1        1     1.00                 1        1     1.00
commit       2056     2132     0.96              2056     2102     0.98
                         0
server rp                0
calls      527239   134383     3.92            527239   133345     3.95


Client nfs v3 stats:
getattr         3       15     0.20                 3        3     1.00
setattr         0        0                          0        0
lookup          3        2     1.50                 3        3     1.00
access         20       20     1.00                20       20     1.00
read       262992    65547     4.01            262992    65560     4.01
write      262145    65537     4.00            262145    65537     4.00
create          1        1     1.00                 1        1     1.00
remove          1        1     1.00                 1        1     1.00
readdir         0        0                          0        0
fsstat          0        0                          0        0
fsinfo          0        0                          0        0
commit       2055     2052     1.00              2055     2052     1.00

client rpc stats:
calls      527220   133175     3.96            527220   133177     3.96
retrans      7509     2242     3.35              7509      620    12.11


I did open a defect to describe the above read problem at:

http://bugme.osdl.org/show_bug.cgi?id=1539


Regards ...Duc



                                                                                                                
                      Eric Whiting                                                                              
                      <ewhiting@amis.com>         To:       trond.myklebust@fys.uio.no, Jason Holmes            
                      Sent by:                     <jholmes@psu.edu>                                            
                      nfs-admin@lists.sour        cc:       nfs@lists.sourceforge.net                           
                      ceforge.net                 Subject:  Re: [NFS] 2.4 vs. 2.6 nfs client performance        
                                                                                                                
                                                                                                                
                      11/13/2003 12:59 PM                                                                       
                                                                                                                
                                                                                                                




Trond Myklebust wrote:
>
>      > This is not the same test, nor the same results as Jason's, but
>      > here is some more data from bonnie and dd tests.This shows some
>      > write performance difference between 2.4 and 2.6 eric
>
> How about vs. 2.4.23?

2.4.23 looks good -- see below -- these are acceptable numbers for a 100M
network. I reran the 2.6.0-test6-mm4 benchmarks and it still is much slower
than
the the 2.4.23.

Question for Jason: -- are you running the 4/4 vm layout in your kernel? My
2.6.0-test6-mm4 has the 4/4 vm enabled -- which can have an impact on
performance. I'll tetest with 2.6.0-test9 without the mm1 and 4/4 vm
enabled.

eric


Linux host 2.4.23-rc1 #2 SMP Thu Nov 13 11:30:02 MST 2003 i686 athlon i386
GNU/Linux
/test> bonnie -s 100
Writing with putc()...  done:   9228 kB/s  52.0 %CPU
Rewriting...            done:   9435 kB/s   6.0 %CPU
Writing intelligently...done:   9235 kB/s   4.0 %CPU

/test> rm file;time dd if=/dev/zero of=file bs=1 count=10000000
10000000+0 records in
10000000+0 records out

real    0m20.086s
user    0m3.120s
sys     0m16.740s


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs






-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
