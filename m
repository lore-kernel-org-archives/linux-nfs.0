From: Glover George <dime@gulfsales.com>
Subject: NFS and lock problems
Date: 18 Mar 2003 16:00:37 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1048024837.22549.18.camel@black.vislab.usm.edu>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mcvs1.otr.usm.edu ([131.95.82.56])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18vP8S-0001Ep-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Mar 2003 14:00:41 -0800
Received: from black.vislab.usm.edu ([131.95.190.25])
	by mcvs1.otr.usm.edu (8.11.6/8.11.6) with ESMTP id h2IM0cX15240
	for <nfs@lists.sourceforge.net>; Tue, 18 Mar 2003 16:00:38 -0600
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

Hello all, please bare with me as I figure this has probably been asked
a million times, but I can't find anything like what I'm looking for.

I have multiple clients and a single server.  The server I am running
redhat 8.0 on, and nfs versions that came with it.  I have a fairly
simple setup.  On the client machines, iptables is set to drop
everything, except it allows all outgoing requests and only allows
incoming ssh. On the server it is the same, except for I am allowing in
a range of ports for nfs.

$IPTABLES -A INPUT -p tcp -s 131.95.190.0/24 --dport 32765:32768 -j
ACCEPT
$IPTABLES -A INPUT -p udp -s 131.95.190.0/24 --dport 32765:32768 -j
ACCEPT

... as per the NFS HOWTO.

I am starting in the startup scripts the following:
daemon rpc.mountd -p 32767 $RPCMOUNTDOPTS
daemon rpc.statd -p 32765 -o 32766

Also, in /etc/modules.conf for lockd i have the following: 
options lockd nlm_udpport=32768 nlm_tcpport=32768

Anything else I may be missing, I'll gladly supply to you.  Let me get
to the problem and the questions. I am having problems it seems with
locking.  When users try to log in with the gnome desktop they get error
messages compaining about nfslockd possibly not running on the server. 
However it is.  Everything as far as nfs is concerned seem to be fine.
Just to be more verbose, here is the output of rpcinfo -p on server and
client respectively.

#server
    program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    391002    2   tcp  32768  sgi_fam
    100011    1   udp    744  rquotad
    100011    2   udp    744  rquotad
    100011    1   tcp    747  rquotad
    100011    2   tcp    747  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
    100005    1   udp  32767  mountd
    100005    1   tcp  32767  mountd
    100005    2   udp  32767  mountd
    100005    2   tcp  32767  mountd
    100005    3   udp  32767  mountd
    100005    3   tcp  32767  mountd
    100024    1   udp  32765  status
    100024    1   tcp  32765  status

#client
[root@black root]# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    391002    2   tcp  32769  sgi_fam
    100021    1   udp  32775  nlockmgr
    100021    3   udp  32775  nlockmgr
    100021    4   udp  32775  nlockmgr
    100024    1   udp  32778  status
    100024    1   tcp  33409  status
    100011    1   udp   1022  rquotad
    100011    2   udp   1022  rquotad
    100011    1   tcp    601  rquotad
    100011    2   tcp    601  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100005    1   udp  32779  mountd
    100005    1   tcp  33410  mountd
    100005    2   udp  32779  mountd
    100005    2   tcp  33410  mountd
    100005    3   udp  32779  mountd
    100005    3   tcp  33410  mountd

Does this look ok for locking? Is there someway i can verify if file
locking is working ok (I only assume that it's not because of that
message, I have no idea how i would test this for sure).  Do i have to
bind the daemons to a specific port on the client as well as the
server?  Do I have to allow initiated connections to any of these
daemons from the server to the client?  I mean, turning off iptables
completely on the clients doesn't help anyway.  Still the same errors. 
Are my options to /etc/modules correct?  I noticed on the server side
that sgi_fam and nfslockmgr are both running on the same port.  Is this
ok?  If not, how do i tell sgi_fam to move to a different port.

One last thing, I haven't implemented this, but just if someone wants to
pipe in, on the server side i want to run rpc.rquotad on a specific
port.  how do i do this with redhat's packages, as i can't use a -p
option. 

I know I'm probably bugging a lot, but I have no idea what's going on
here, as everything has always worked for me when i simply use KDE, but
this problem is plaguing me.  I'd like to know if maybe i've done
something wrong or just have the whole wrong idea about it.

Much thanks in advance.

-- 
Glover George
Systems Administrator
High Performance Visualization Lab
University of Southern Mississippi
glover.george@usm.edu
(601) 266-5634



-------------------------------------------------------
This SF.net email is sponsored by: Does your code think in ink? 
You could win a Tablet PC. Get a free Tablet PC hat just for playing. 
What are you waiting for?
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
