From: Arnau Bria <arnau@emergetux.net>
Subject: nfs problem
Date: Thu, 25 Jan 2007 15:31:53 +0100
Message-ID: <20070125153153.23f5df6a@lx-arnau.pic.es>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HA5f0-00025r-FA
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 06:33:06 -0800
Received: from 41.red-80-37-233.staticip.rima-tde.net ([80.37.233.41]
	helo=afrodita.emergetux.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HA5ez-0005xn-Fo
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 06:33:08 -0800
Received: from lx-arnau.pic.es (lx-arnau.pic.es [193.146.196.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by afrodita.emergetux.net (Postfix) with ESMTP id C95217C16C
	for <nfs@lists.sourceforge.net>; Thu, 25 Jan 2007 15:32:03 +0100 (CET)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

I have a new nfs server with this env:

[root@cdf-nfsserver root]# uname -a
Linux cdf-nfsserver 2.4.21-32.0.1.ELsmp #1 SMP Wed May 25
15:42:26 CDT 2005 i686 i686 i386 GNU/Linux 

[root@cdf-nfsserver root]#rpm -qa|grep nfs nfs-utils-1.0.6-33EL
redhat-config-nfs-1.0.13-6

[root@cdf-nfsserver root]# cat /etc/redhat-release
Scientific Linux release 3.0.5 (Fermi)

and a client with same redhat-release, nfs-utils package version and
diff kernel:

[root@cdf-bcnhead init.d]# uname -a
Linux cdf-bcnhead 2.4.21-47.0.1.ELsmp #1 SMP Thu Oct 19
10:46:05 CDT 2006 i686 i686 i386 GNU/Linux

I'm noticing that communication between them is very slow, but they
share switch, so shouldn't be bad. No errors packets reported in
ifconfig:
RX packets:219163615 errors:0 dropped:0 overruns:0 frame:0
TX packets:264718776 errors:0 dropped:0 overruns:0 carrier:0


Looking into logs I found this messages in server (cdf-nfsserver)

cdf-nfsserver rpc.statd[3294]: Received erroneous SM_UNMON request from
IP_SERVER for IP_CLIENT 

cdf-nfsserver rpc.statd[3294]: Received erroneous SM_UNMON request from
IP_SEVER for IP_CLIENT

and in the client: (cdf-bcnhead)

cdf-bcnhead rpc.statd[11731]: Received erroneous SM_UNMON request from
IP_CLIENT for IP_SERVER

cdf-bcnhead rpc.statd[11731]: Received erroneous SM_UNMON request from
IP_CLIENT for IP_SERVER

*I have modified values of IP_SERVER-IP_CLIENT*

and looking into client's dmesg I find lots of connection lost
messages:

nfs: server IP_SERVER not responding, still trying
nfs: server IP_SERVER OK

and nothing in server.


As I don't know if the error come from server/client, I've checked Nfs
server processes:

[root@cdf-nfsserver root]# uptime
 11:05:05  up 1 day, 23:09,  1 user,  load average: 0.00, 0.02, 0.00
[root@cdf-nfsserver root]# ps -ef|grep nfs
root      2931     1  0 Jan23 ?        00:12:31 [nfsd]
root      2932     1  0 Jan23 ?        00:12:08 [nfsd]
root      2933     1  0 Jan23 ?        00:11:27 [nfsd]
root      2934     1  0 Jan23 ?        00:12:00 [nfsd]
root      2935     1  0 Jan23 ?        00:12:40 [nfsd]
root      2936     1  0 Jan23 ?        00:11:12 [nfsd]
root      2937     1  0 Jan23 ?        00:11:59 [nfsd]
root      2938     1  0 Jan23 ?        00:12:27 [nfsd]

It is up for one day, and nfsd processes have consumed more than 12
minuts, is this normal?


First google search pointed me to statd directory's permits:

# ls -lsad /var/lib/nfs/statd
   4 drwx------    4 rpcuser  rpcuser      4096 Jan 17
10:19 /var/lib/nfs/statd

but seems correct in both server and client.

Second search recommends a downgrade of nfs-utils, but before doing so,
I'd like to confirm that this is the only solution.

This is server conf:
# cat /etc/exports
/home/cdfcaf    NET.0/255.255.252.0(rw,async,no_root_squash)
/home/cdfsoft   NET.0/255.255.252.0(rw,async,no_root_squash)
/home/cafmon    NET.0/255.255.252.0(rw,async,no_root_squash)
/home/sam       NET.0/255.255.252.0(rw,async,no_root_squash)

and client uses autofs:

# cat /etc/auto.master
/home /etc/auto.home --timeout=600

# cat /etc/auto.home
cdfcaf          -rw,hard,intr,async,rsize=8192,wsize=8192
IP_SERVER:/home/cdfcaf cdfsoft
-rw,hard,intr,async,rsize=8192,wsize=8192 IP_SERVER:/home/cdfsoft
sam             -rw,hard,intr,async,rsize=8192,wsize=8192
IP_SERVER:/home/sam cafmon
-rw,hard,intr,async,rsize=8192,wsize=8192 IP_SERVER:/home/cafmon


Anyone knows where is the source of this problem?

Thanks in advance,
Arnau

PS: sorry to admins, I used a non subscribed account for my first
post :-(

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
