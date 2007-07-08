From: David Liontooth <liontooth@cogweb.net>
Subject: NFS using iptables PREROUTING?
Date: Sun, 08 Jul 2007 09:18:24 -0700
Message-ID: <46910E50.2020000@cogweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7ZSu-0004Ia-8e
	for nfs@lists.sourceforge.net; Sun, 08 Jul 2007 09:18:28 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I7ZSw-00055l-Mt
	for nfs@lists.sourceforge.net; Sun, 08 Jul 2007 09:18:31 -0700
Received: from TimTi-2.local (adsl-75-56-200-174.dsl.lsan03.sbcglobal.net
	[75.56.200.174])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l68GINFq004560
	for <nfs@lists.sourceforge.net>; Sun, 8 Jul 2007 09:18:23 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Is it possible to access an NFS server on a private network from a 
machine on a public network?

I have a Debian box B on a private network visible only to a gateway G. 
B has drive partitions I would like to mount on outside box A.
To make B visible to A, I use this sort of thing for ssh:

  iptables -t nat -A PREROUTING -p tcp -d 128.65.183.178 --dport 9000 -j 
DNAT --to 192.168.0.1:22

This allows me to ssh directly from A to B, as if B were on a public 
network. Can I do the same with NFS?

So far, I've figured out how to fix the port of mountd, statd, and 
lockd, and I can preroute these ports, along with 2049 for nfs and 111 
for portmap.
For each of these, I can preroute tcp and udp packets on G:

# Forward tcp and udp on port 111 for portmap on A
  iptables -t nat -A PREROUTING -p tcp -d 128.65.183.178 --dport 9200 -j 
DNAT --to 192.168.0.3:111
  iptables -t nat -A PREROUTING -p udp -d 128.65.183.178 --dport 9200 -j 
DNAT --to 192.168.0.3:111

# Forward tcp and upd for port 2049 for nfs to A (tcp may not be needed)   
  iptables -t nat -A PREROUTING -p tcp -d 128.65.183.178 --dport 9201 -j 
DNAT --to 192.168.0.3:2049
  iptables -t nat -A PREROUTING -p udp -d 128.65.183.178 --dport 9201 -j 
DNAT --to 192.168.0.3:2049

# Forward tcp and udp for lockd (port assigned in A:/boot/grub/menu.lst)
  iptables -t nat -A PREROUTING -p tcp -d 128.65.183.178 --dport 9202 -j 
DNAT --to 192.168.0.3:4000
  iptables -t nat -A PREROUTING -p udp -d 128.65.183.178 --dport 9202 -j 
DNAT --to 192.168.0.3:4000

# Forward tcp and udp for mountd (port assigned in 
A:/etc/default/nfs-common)
  iptables -t nat -A PREROUTING -p tcp -d 128.65.183.178 --dport 9203 -j 
DNAT --to 192.168.0.3:4001
  iptables -t nat -A PREROUTING -p udp -d 128.65.183.178 --dport 9203 -j 
DNAT --to 192.168.0.3:4001

# Forward tcp and udp for statd (port assigned in A:/etc/default/nfs-common)
  iptables -t nat -A PREROUTING -p tcp -d 128.65.183.178 --dport 9204 -j 
DNAT --to 192.168.0.3:4002
  iptables -t nat -A PREROUTING -p udp -d 128.65.183.178 --dport 9204 -j 
DNAT --to 192.168.0.3:4002
# Do you need a POSTROUTING line to take outgoing tcp/udp for statd on 
port 4003?

However, at this point I get a sinking feeling this is still not possible.

Is there a way on the client A to specify where to look for the 
different NFS resources on B (via G)?

How do I tell NFS that for this particular mount B, and only for B, 
portmap is on 9200, nfs is on 9201, lockd on 9202, mountd on 9203, and 
statd on 9204?
Can I specify all of this in /etc/fstab? For ssh, I can specify 
host:port in /etc/ssh/ssh_config, but it uses only one service.

On A, I also mount several other NFS drives, and they need the default 
ports.
G, the gateway, also exports its own drives to A via NFS, using the 
default ports.

I would prefer straight NFS with iptables to ssh tunneling, but can it 
be done?

Cheers,
Dave



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
