From: Sfondrini Cesare <cesare.sfondrini@tin.it>
Subject: Help for setting NFS
Date: 09 Dec 2002 00:04:13 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1039388658.925.29.camel@sfondrin-home>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from vsmtp3.tin.it ([212.216.176.223] helo=smtp3.cp.tin.it)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18L9Tl-0006Ng-00
	for <nfs@lists.sourceforge.net>; Sun, 08 Dec 2002 14:00:49 -0800
Received: from host202-90.pool212171.interbusiness.it (212.171.90.202) by smtp3.cp.tin.it (6.5.029)
        id 3DDD788200657968 for nfs@lists.sourceforge.net; Sun, 8 Dec 2002 23:00:44 +0100
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

Hi to everyone,

I'm searching for help for setting NFS between two machines (my home
Linux host and my laptop)

I've red the Linux NFS HOW-TO doc (thanks to Tavis, Nicolai, Seth and
Tom) but the system is not working.

The Problem: when I search to mount to any of the exported directories
I've a message "RPC timed out" from the client and in /var/log/messages
I don't find any useful message (the log line is "athenticated request
for /home/cesare ...." and the following line says "the above message
repeated 6 time

For max precision this is the message on server side
"Dec  8 16:06:04 sfondrin-home rpc.mountd: authenticated mount request
from sfondrin-port:950 for /home/cesare (/home/cesare)"
Dec  8 16:06:23 sfondrin-home last message repeated 6 times


If someone can help me I provide the information on my systems:

0. the machines are connected with an honest cross cable
1. The server machine is running red hat server edition 8.0
2. The output of uname -a is 
	Linux sfondrin-home 2.4.18-14 #1 Wed Sep 4 12:13:11 EDT 2002 	i686
athlon i386 GNU/Linux
3. The /etc/exports file follows:

	/home/cesare	sfondrin-port(rw,insecure,sync,no_wdelay,no_subtree_check,insecure_locks,no_root_squash)
	/home/laptop sfondrin-port(rw,sync)
	/home/local sfondrin-port(rw,sync)
	/home/boss sfondrin-port(rw,sync)

4. The output of rpcinfo -p pn the server machine (sfondrin-home) is:  
program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam
    100011    1   udp    780  rquotad
    100011    2   udp    780  rquotad
    100011    1   tcp    783  rquotad
    100011    2   tcp    783  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100005    1   udp  32771  mountd
    100005    1   tcp  32770  mountd
    100005    2   udp  32771  mountd
    100005    2   tcp  32770  mountd
    100005    3   udp  32771  mountd
    100005    3   tcp  32770  mountd

The same output I've when run rpcinfo -p on the client machine and when
I run rpcinfo -p <server-name>

5. The host.allow file follows (I've left obvious security hole that I
close in future when I resolve my NFS problem). the file is strange
enough (I've inserted the IP address of the server machine and the ALL
after I've tried with a "polite " file as indicated in the how to doc.
#
# hosts.allow   This file describes the names of the hosts which are
#               allowed to use the local INET services, as decided
#               by the '/usr/sbin/tcpd' server.
#
portmap: ALL , 10.58.18.111 , 10.58.18.112
lockd: ALL , 10.58.18.111 , 10.58.18.112
rquotad: ALL , 10.58.18.111 , 10.58.18.112
mountd: ALL , 10.58.18.111 , 10.58.18.112
statd: ALL , 10.58.18.111 , 10.58.18.112
nfsd: ALL , 10.58.18.111 , 10.58.18.112
# ALL: LOCAL 10.58.
 

6. From my laptop Client I can:
	ping the server
	ftp to my server
	telnet to my server
	
	So I suppose the problem is not a networking one (neither level three
or level 4)


Could you help me about the problem ?



Thanks in advance for your help.


Cesare 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
