From: Robert Rati <Robert.Rati@motorola.com>
Subject: NFS through firewall
Date: Mon, 03 Mar 2003 18:10:51 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E63EF0B.2070903@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from motgate5.mot.com ([144.189.100.105])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18q01F-0004X0-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Mar 2003 16:10:53 -0800
Received: from pobox.mot.com (pobox.mot.com [129.188.137.100])
	by motgate5.mot.com (Motorola/Motgate5) with ESMTP id h240AZLH002702
	for <nfs@lists.sourceforge.net>; Mon, 3 Mar 2003 17:10:35 -0700 (MST)
Received: [from il02exm02.corp.mot.com (il02exm02.corp.mot.com [10.0.100.55]) by pobox.mot.com (MOT-pobox 2.0) with ESMTP id RAA23549 for <nfs@lists.sourceforge.net>; Mon, 3 Mar 2003 17:10:51 -0700 (MST)]
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

I am trying to provide a directory to the outside world through a 
firewall via NFS.  I can mount the directory from another system, but 
when I try to list the contents of the directory the firewall blocks the 
communication.  I see that the host system is attempting to send data on 
port 65535 using the UDP protocol.  I have the following firewall rule 
that SHOULD match it, but isn't:

/sbin/ipchains -A output -j ACCEPT -i eth0 -p udp --source-port 61000:65535

I have set the local port range to be 61000-65535.  My question is, why 
is NFS choosing port 65535 to transfer data?  Is it using the local port 
range?  I tried changing the port range and restarting the NFS daemons, 
but it still tried to use port 65535.

I know this isn't necessarily a firewall expert group, but have there 
been any issues with ipchains/2.2 kernels blocking NFS traffic on port 
65535?

Rob



-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
