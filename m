From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: mountd gives "illegal port"
Date: Wed, 27 Oct 2004 23:13:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041027211303.GD27180@fi.muni.cz>
References: <20041027124228.GJ4724@fi.muni.cz> <3412.1098911073@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMv6U-00067D-G0
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 14:13:10 -0700
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CMv6T-00061t-AZ
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 14:13:10 -0700
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <3412.1098911073@marajade.sandelman.ottawa.on.ca>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Michael Richardson wrote:
:   What version are you using?
:   On client? on server?
: 
	Kernel 2.6.9 on both hosts (server is x86-64, client i386),
client nfs-utils-1.0.6-22 on Fedora Core 2, server nfs-utils-1.0.6-34
on Fedora Core 3 test 3.

:     Jan> And in NFS server the following is added to syslog:
: 
:     Jan> Oct 27 14:28:48 nfs-server rpc.mountd: refused mount request
:     Jan> from nfs-client.fi.muni.cz for /tmp/nfs/6 (/tmp/nfs/6): illegal
:     Jan> port 54071
: 
:   Does your server expect to see reserved ports only (<1024).

	Yes (there is no "insecure" option in /etc/exports).

:   Can you do a tcpdump of the mounts?
: 
	Yes - I did. The failing mount request uses unprivileged source port
unlike the previous ones.

:     tcpdump -s 1600 -i eth0 -n -p -w somefile.pcap udp port X or tcp port X
: 
: 
:   tcpdump -r somefile.pcap -T rpc -n 

	I will do this on Monday - now I am not nowhere near these servers.

	But as I said, the problem is that the client runs out of privileged
ports, because both portmap request and mountd request are done over TCP.

-Yenya

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
> Whatever the Java applications and desktop dances may lead to, Unix will <
> still be pushing the packets around for a quite a while.      --Rob Pike <


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
