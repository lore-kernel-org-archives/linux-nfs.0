From: Robert Myers <rmyers1400@attbi.com>
Subject: Re: NFS through firewall
Date: Mon, 03 Mar 2003 21:40:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E64120E.4050403@attbi.com>
References: <3E63EF0B.2070903@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18q2Lr-0001oj-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Mar 2003 18:40:19 -0800
To: Robert Rati <Robert.Rati@motorola.com>
In-Reply-To: <3E63EF0B.2070903@motorola.com>
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

Robert Rati wrote:

> I am trying to provide a directory to the outside world through a 
> firewall via NFS.  I can mount the directory from another system, but 
> when I try to list the contents of the directory the firewall blocks 
> the communication.  I see that the host system is attempting to send 
> data on port 65535 using the UDP protocol.  I have the following 
> firewall rule that SHOULD match it, but isn't:
>
> /sbin/ipchains -A output -j ACCEPT -i eth0 -p udp --source-port 
> 61000:65535 

Is this an  output chain on the client side?  Why should that cause the 
client to accept a communication on 65535?  Happens all the time: client 
requests data on port x, declines the response on port x.  Go figure.

Without seeing your entire ipchains config (and I wouldn't recommend 
posting it), I can't suggest a one-line fix,  but somewhere you need

/sbin/ipchains -A input -j ACCEPT -i eth0 -p  udp --source-port 61000:65535,

but I wouldn't recommend it.  Instead, specify that NFS use a port in 
the reserved range (1-1024) and don't open a hole in your firewall where 
hackers often lurk.

Check out

http://www.ibiblio.org/pub/Linux/docs/HOWTO/other-formats/html_single/NFS-HOWTO.html

for how to specify what port NFS is using.

RM



-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
