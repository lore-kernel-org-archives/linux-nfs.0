From: Andrew Theurer <habanero@us.ibm.com>
Subject: more SMP issues
Date: Tue, 26 Mar 2002 13:22:46 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200203261934.NAA25602@popmail.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Received: from mg02.austin.ibm.com ([192.35.232.12])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pwiT-0000YA-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 11:34:45 -0800
Received: from austin.ibm.com (netmail2.austin.ibm.com [9.3.7.139])
	by mg02.austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id NAA13516
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 13:44:22 -0600
Received: from popmail.austin.ibm.com (popmail.austin.ibm.com [9.53.247.178])
	by austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id NAA34580
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 13:34:40 -0600
Received: from there (crashandburn.austin.ibm.com [9.53.216.41]) by popmail.austin.ibm.com (AIX4.3/8.9.3/8.7-client1.01) with SMTP id NAA25602 for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 13:34:40 -0600
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,

I am still seeing some scaling problems with my SMP nfs server, so I did some 
more tests.  I has suspected that there were not enough nfsd threads actually 
doing work, since my run queue was so short (2 or less) and CPU utilization 
was below 35% (this is a 4-way SMP).  So, before the tests, I added nfsd_busy 
to /proc/net/rpc/nfsd, so I could monitor exactly how many nfsd threads were 
getting to svc_process() at any point in time.  I would then monitor this 
during my tests, so I know how many nfsd threads are actually getting to 
svc_process().  

My first test is a NFS client read test.  48 clients each read a 200MB file 
from the same server.  The elapsed time is recorded for all the clients to 
finish, and then the throughput is calculated.  Results from this test 
 raised concerns because I did not see a significant improvement from 
uniprocessor to 4-way.  I had been running this test for udp and this would 
be the result:

Test    SMP CPU proto vers rwsize nfsdcount nfsdbusy secs MB/sec NFSops/sec
nfsread 4P   34  udp   3    8k     128       1        109   88     11009

nfsd_busy would never exceed 1 in this test.  I have tried with various qty 
of nfsd threads, and it always has just one busy thread with one exception:  
If I set the number of nfsd threads to 2, nfsd_busy will stay at 2 75% of the 
time during the test, CPU util will be about 55%, and I'll get maybe 15-20% 
better throughput.  If the nfsd thread count is set to anything else, 
nfsd_busy will not exceed 1.  

I decided to try tcp protocol just to get a comparison, and surprisingly it 
_could_ have more than 1 for nfsd_busy:

Test    SMP CPU proto vers rwsize nfsdcount nfsdbusy secs MB/sec NFSops/sec
nfsread 4P  100 tcp    3    8k     128       12       110   87     10903

Nfsd_busy reached a maximum of 12, and probably averaged around 8 during 
the test.  The performance was not better, but I still don't understand why 
there can be more than one nfsd thread busy with tcp, and not with udp??  I 
know that having nfsd_busy at 2 with udp improves performance.  If we can get 
udp to consistently use more than one thread at one time, I think we can 
boost performance quite a bit. 

Now, I was concerned that I may have some sort of network throughput 
limitation here, since I was close to 100MB/sec, and in my experience, even 
with multiple Gbps adapters (I have 4), the mem copies involved here tend to 
saturate the poor 100 MHz memory bus this server has.  I was not sure if this 
was causing a problem here, so I setup an other test.  This time all 48 
clients do a "ls -lR" on a 2.5.7 kernel tree on the server.  This generates a 
very high number of nfs requests with relatively low network throughput 
compared the the read test.  Total network throughput was under 4 MB/sec 
(send and recv).  Here are the results:

Test    SMP CPU proto vers rwsize nfsdcount nfsdbusy secs MB/sec NFSops/sec
nfsls   4P  100  tcp   3    8k     128       11       127    -    30538
nfsls   4P  34   udp   3    8k     128        1       112    -    34750

Again, with udp I cannot get nfsd_busy to exceed 1.  TCP has the same 
behavior as the last test.  My first thought was that maybe the way the bits  
are set and cleared for the socket (SK_BUSY, SK_DATA, SK_CONN, etc) could be 
causing a problem here, but I cannot confirm that.  It appears they behave 
the same way for tcp and udp, so that is probably not it.  So, I am now stuck 
here.  If there is anyone interested in helping me investigate this (Neil?), 
please let me know. Thanks for your help.

-Andrew

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
