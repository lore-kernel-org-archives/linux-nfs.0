From: Jeff Davis <jdavis@hess.com>
Subject: Re: round robin dns, multihomed host, nfs mounting issues
Date: Mon, 22 Sep 2003 14:50:38 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1064260237.30825.13.camel@oac195>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1Whl-0001lV-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 12:50:41 -0700
Received: from [63.105.228.197] (helo=outside.ep.hess.com)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1Whk-0001bO-Qu
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 12:50:40 -0700
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
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



Client ip - 172.25.1.108

Server eth0 - 172.25.2.120 (default gateway 172.25.2.119)
Server eth1 - 192.168.19.221

No firewall

OOT:beo408:/root# ps -ef | grep ipchain
root     15474 13106  0 13:53 pts/0    00:00:00 grep ipchain
ROOT:beo408:/root# ps -ef | grep iptable
root     15476 13106  0 13:54 pts/0    00:00:00 grep iptable
ROOT:beo408:/root# lsmod | grep ip
ROOT:beo408:/root# 


No /etc/hosts.allow or /etc/hosts.deny entries on server

rpcinfo -p localhost (on server)

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
    100007    2   udp    630  ypbind
    100007    1   udp    630  ypbind
    100007    2   tcp    633  ypbind
    100007    1   tcp    633  ypbind
    100024    1   udp    836  status
    100024    1   tcp    843  status
    100001    3   udp    850  rstatd
    100001    2   udp    850  rstatd
    100001    1   udp    850  rstatd
    100011    1   udp    748  rquotad
    100011    2   udp    748  rquotad
    100011    1   tcp    751  rquotad
    100011    2   tcp    751  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100005    1   udp    833  mountd
    100005    1   tcp    849  mountd
    100005    2   udp    833  mountd
    100005    2   tcp    849  mountd
    100005    3   udp    833  mountd
    100005    3   tcp    849  mountd

ROOT:beo408:/root# cat /etc/hosts.deny
#
# hosts.deny    This file describes the names of the hosts which are
#               *not* allowed to use the local INET services, as decided
#               by the '/usr/sbin/tcpd' server.
#
# The portmap line is redundant, but it is left to remind you that
# the new secure portmap uses hosts.deny and hosts.allow.  In particular
# you should know that NFS uses portmap!

ROOT:beo408:/root# cat /etc/hosts.allow
#
# hosts.allow   This file describes the names of the hosts which are
#               allowed to use the local INET services, as decided
#               by the '/usr/sbin/tcpd' server.
#


Non-local subnet client trying to talk to server eth1 interface

ROOT:beo408:/root# rpcinfo -u 192.168.19.221 mountd 3
rpcinfo: RPC: Port mapper failure - RPC: Timed out
program 100005 version 3 is not available

ROOT:beo408:/root# rpcinfo -u 192.168.19.221 mountd 3
rpcinfo: RPC: Port mapper failure - RPC: Timed out
program 100005 version 3 is not available

ROOT:beo408:/root# host beo408 
beo408.ep.hess.com has address 172.25.1.108

ROOT:beo408:/root# rpcinfo -u 172.25.2.120 mountd 3
program 100005 version 3 ready and waiting

ROOT:beo408:/root# host 172.25.2.120               
120.2.25.172.in-addr.arpa domain name pointer lfscluster01.ep.hess.com.

ROOT:beo408:/root# host 192.168.19.221
221.19.168.192.in-addr.arpa domain name pointer
lfscluster01.ep.hess.com.

ROOT:beo408:/root# rpcinfo -u 192.168.19.221 mountd 3
rpcinfo: RPC: Port mapper failure - RPC: Timed out
program 100005 version 3 is not available



Local subnet client trying to talk to server eth1 interface



Client ip - 192.168.19.1 

Server eth0 - 172.25.2.120 (default gateway 172.25.2.119)
Server eth1 - 192.168.19.221


eo001> host beo001
beo001.ep.hess.com has address 192.168.19.1
beo001> rpcinfo -u 192.168.19.221 mountd 3
program 100005 version 3 ready and waiting
beo001> rpcinfo -u 192.168.19.221 mountd 3
program 100005 version 3 ready and waiting


let's try 172.25.2.120 interface from 192.168.19 subnet

beo001> rpcinfo -u 172.25.2.120 mountd 3  
program 100005 version 3 ready and waiting

this works, is it because this is the default gateway?


also, neil mentioned putting default route on each interface?
is this ok? 

thanks



previous messages follow









On Saturday July 19, jdavis@hess.com wrote:
> 
> Given Neil's comments about possible glibc bug and nfs 1.05, and my
sense that it is working, is it reasonable for me to think its working?

> 
> I.e should it work?

Maybe.

It is entirely possible that I mis-diagnosed your problem.  If your
NFS server is the only route between the two subnets, I probably did.  

However I cannot think of any recent change in nfs-utils that would
affect anything like your problem, but then my memory isn't perfect.

I suggest you test your configuration and if it works, be happy.

When I had the problem I mentioned, I used rpcinfo for testing:

  rpcinfo -u $HOSTNAME mountd 3

If run this on a representative sample of clients, using a
representative sample of server IP address, and it always works, then
I guess your problem has gone away

NeilBrown


On  July 18, jdavis@hess.com wrote:
> I'm testing out a NFS server which has two interfaces on two different
> subnets. I'm using a single hostname and round robin dns. Clients are
> both RedHat Linux systems.
> 
> I can access the primary interface on server via NFS from any system
on
> my network. I can only access the second interface from hosts on the
> same subnet. Unfortunately, round robin dns on systems that are not
> local to subnets on either of the server's nics will randomly get one
of
> the two nics to access nfs fs through. 
> 
> int 1 - 192.168.19.224
> int 2 - 172.25.2.106
> 
> # can mount through int 1 from any host\
> # can mount thoughh int 2 from same ip subnet as int 2
> # cannot mount throught int 2 from remote ip subnets
> # on local subnets, mounts work as desired through correct, optimal
> interface on nfs server
> 
> # on remote subnets, round robin directs ~50% of mount requests
> to server through int 2 which fail
> 
> why doesn't this work?

Looks like you've hit a glibc bug that was only fixed relatively
recently (27th Feb 2003.  glibc version 2.3.2 or 2.3.3 I think).

When mountd is sending it's reply, it uses sendmsg and insists that the
reply goes out the same interface that the request came in on.  If
that interface doesn't have a route to the client, you lose.

I worked around it by putting a default route on all my interfaces.

> upgrading to nfs-utils 1.05 seems to have helped

I doubt that it really did, but if it works now, great.

NeilBrown
-- 

Jeff Davis
Amerada Hess Corporation
Global IT Technical Computing Infrastructure
Houston, Texas
jdavis@hess.com
Office: 713-609-5436
Mobile: 281-467-9448
http://www.jrdavis.net/


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
