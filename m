From: Louis Garcia <louisg00@bellsouth.net>
Subject: nfs client and iptables
Date: 17 May 2002 19:54:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021679697.5635.12.camel@tiger>
References: <1021587354.1123.29.camel@tiger>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail108.mail.bellsouth.net ([205.152.58.48] helo=imf08bis.bellsouth.net)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178rXq-0001fO-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 16:53:58 -0700
Received: from tiger ([208.61.41.20]) by imf08bis.bellsouth.net
          (InterMail vM.5.01.04.05 201-253-122-122-105-20011231) with ESMTP
          id <20020517235516.DMG17991.imf08bis.bellsouth.net@tiger>
          for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 19:55:16 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <1021587354.1123.29.camel@tiger>
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

I'm just trying to teach myself how to configure a filewall using
iptables. This is my current script:

## Set up a default DROP policy for the built-in chains.
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

## LOOPBACK
# Allow unlimited traffic on the loopback interface.
iptables -A INPUT -i lo -j ACCEPT

## SYN-FLOODING PROTECTION
iptables -N syn-flood
iptables -A INPUT -i eth0 -p tcp --syn -j syn-flood
iptables -A syn-flood -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -A syn-flood -j DROP

## Make sure NEW tcp connections are SYN packets
iptables -A INPUT -i eth0 -p tcp ! --syn -m state --state NEW -j DROP

## FRAGMENTS
# Log fragments just to see if we get any, and deny them too.
iptables -A INPUT -i eth0 -f -j LOG --log-prefix "IPTABLES FRAGMENTS: "
iptables -A INPUT -i eth0 -f -j DROP

## SPOOFING
# Refuse spoofed packets pretending to be from your IP address.
iptables -A INPUT -i eth0 -s 192.168.1.4/27 -j DROP
# Refuse packets claiming to be from a Class A private network.
iptables -A INPUT -i eth0 -s 10.0.0.0/8 -j DROP
# Refuse packets claiming to be from a Class B private network.
iptables -A INPUT -i eth0 -s 172.16.0.0/12 -j DROP
# Refuse packets claiming to be from a Class C private network.
iptables -A INPUT -i eth0 -s 192.168.0.0/16 -j DROP
# Refuse Class D multicast addresses. Multicast is illegal as a source
# address.
iptables -A INPUT -i eth0 -s 224.0.0.0/4 -j DROP
# Refuse Class E reserved IP addresses.
iptables -A INPUT -i eth0 -s  240.0.0.0/4 -j DROP
# Refuse packets claiming to be to the loopback interface.
iptables -A INPUT -i eth0 -d 127.0.0.1/27 -j DROP
# Refuse broadcast address packets.
iptables -A INPUT -i eth0 -d 192.168.1.31 -j DROP

## DNS server access (53)
# Allow UDP packets in for DNS client from nameservers.
iptables -A INPUT -i eth0 -p udp -s 205.152.16.20 --sport 53 -m state \
--state ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p udp -s 205.152.0.5 --sport 53 -m state \
--state ESTABLISHED -j ACCEPT

## Web sites access (80,443 tcp)
# Allow www surfing (HTTP). (80)
iptables -A INPUT -i eth0 -p tcp --sport 80 -m state --state \
ESTABLISHED -j ACCEPT
# Allow secure www surfing (HTTPS). (443)
iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state \
ESTABLISHED -j ACCEPT

## POP (110)
# Allow to send mail to remote server.
iptables -A INPUT -i eth0 -p tcp --sport 110 -m state --state \
ESTABLISHED -j ACCEPT

## SMTP (25)
# Allow to retrieve mail from remote server.
iptables -A INPUT -i eth0 -p tcp --sport 25 -m state --state \
ESTABLISHED -j ACCEPT

## NTTP (119)
# Allow news from remote hosts.
iptables -A INPUT -i eth0 -p tcp --sport 119 -m state --state \
ESTABLISHED -j ACCEPT

## FTP (20,21,1024:65535)
# Allow ftp to remote systems. (21)
iptables -A INPUT -i eth0 -p tcp --sport 21 -m state --state \
ESTABLISHED -j ACCEPT
# 1) Active ftp. (20)
iptables -A INPUT -i eth0 -p tcp --sport 20 -m state --state \
ESTABLISHED,RELATED -j ACCEPT
# 2) Passive ftp. (1024:65535)
iptables -A INPUT -i eth0 -p tcp --sport 1024:65535 --dport 1024:65535 \
  -m state --state ESTABLISHED -j ACCEPT

## IRC (6777)
# Allow xchat to access remote hosts.
iptables -A INPUT -i eth0 -p tcp --sport 6777 -m state --state \
ESTABLISHED -j ACCEPT

I'm on a private network (192.168.1.0/27) and my nfs server is (192.168.1.1/27)
I still need help with mounting nfs shares, accessing ssh remote systems,
ping and traceroute out. Can someone help me out, at least the nfs part?

Thanks, --Louis



_______________________________________________________________

Hundreds of nodes, one monster rendering program.
Now that’s a super model! Visit http://clustering.foundries.sf.net/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
