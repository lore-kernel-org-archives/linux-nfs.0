From: Philippe Troin <phil@fifi.org>
Subject: Re: NFS through firewall
Date: 03 Mar 2003 16:33:09 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87n0kct1h6.fsf@ceramic.fifi.org>
References: <3E63EF0B.2070903@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18q0NS-0001GD-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Mar 2003 16:33:50 -0800
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

Robert Rati <Robert.Rati@motorola.com> writes:

> I am trying to provide a directory to the outside world through a
> firewall via NFS.  I can mount the directory from another system, but
> when I try to list the contents of the directory the firewall blocks
> the communication.  I see that the host system is attempting to send
> data on port 65535 using the UDP protocol.  I have the following
> firewall rule that SHOULD match it, but isn't:
> 
> /sbin/ipchains -A output -j ACCEPT -i eth0 -p udp --source-port 61000:65535
> 
> I have set the local port range to be 61000-65535.  My question is,
> why is NFS choosing port 65535 to transfer data?  Is it using the
> local port range?  I tried changing the port range and restarting the
> NFS daemons, but it still tried to use port 65535.
> 
> I know this isn't necessarily a firewall expert group, but have there
> been any issues with ipchains/2.2 kernels blocking NFS traffic on port
> 65535?

It's a fragment, which will match with -f in ipchains.

Alternately, you may set the net.ipv4_always_defrag sysctl, or (for
2.4), insmod ip_conntrack.

Phil.


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
