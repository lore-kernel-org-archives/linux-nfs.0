From: Peter Niessen <niessen@ifh.de>
Subject: NFS/NAT(MASQUERADING) trouble
Date: Wed, 18 Sep 2002 14:41:27 +0200 (METDST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.HPX.4.33.0209181349480.28921-100000@hpbai1.ifh.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Steven Lowette <lowette@hep.iihe.ac.be>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from znsun1.ifh.de ([141.34.1.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17re9I-0000OG-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 05:41:45 -0700
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hi,

after days of searching the net, my frustration amounts to levels
which urge me to write to the experts. I have the following problem:

We've set up a PC farm of 9 client and a master machine, running
2.4.18 (debian) in the following way:


alpha server =3D NFS/NIS server
\
 \
  \
  XXXXXXXX switch
   /
  /
 / eth0=3Dpublic ip,
Mastermachine with two interfaces eth0/eth1
\  eth1=3D192.168.0.199
 \
  \
   \
    \
    XXXXXXXXX...XXXXXXXX switch
           |  |  | ... |  |  |
 192.168.0.1 .2 .3 ...      .9

iptables is used to run the masquerading/nat on the master machine.
After rebooting, everything runs smooth and the client machines and the
master machine can see the NFS disks on the alpha server and the NIS
works o.k. After some while, i.e. several hours in which the client
machines access the NFS server (running jobs under the PBS batch
system), the master machine, and only this one, gets into trouble.
First, it will loose the disk which the clients write to (1000 files
of ~2MB size, roughly ten of them within a minute in 10 minute
intervals + a ~kB logfile and an empty status file), then other disks
on the server. The clients are still able to see the server through
the master, NFS as well as NIS.

I use the NAT-script at the end of the message, copied from c't 4/2002.

Now, I found that people report similar behaviour when using INTEL
boards with certain NICs (cf. eg.
http://sourceforge.net/mailarchive/message.php?msg_id=3D550848). But why
would the client machines still see the NFS?

If anyone has a similar set-up, I'd be glad to hear/read about it.

Cheers and thanks in advance, Peter.

#!/bin/sh

echo 1 > /proc/sys/net/ipv4/ip_forward

modprobe ip_tables iptable_filter ip_conntrack ip_conntrack_ftp
modprobe iptable_nat ip_nat_ftp ipt_LOG ipt_MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.0.0/16 -j MASQUERADE

and iptables -t nat -L gives

master:~# iptables -t nat -L
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  192.168.0.0/16       anywhere

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

Peter Nie=DFen
VUB Brussels
Dienst ELEM
Pleinlaan 2
B-1050 Brussels
Belgium

Tel (+32)2/629-3554, -3651 (lab)
Fax (+32)2/629-3816
e-mail niessen@ifh.de
www http://www.ifh.de/~niessen

 /"\  ASCII ribbon campaign
 \ /  ---------------------
  X     against HTML mail
 / \      and postings

pgp public key at

http://www.ifh.de/www_users/amanda/niessen/www/pgp_pubkey.asc



-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
