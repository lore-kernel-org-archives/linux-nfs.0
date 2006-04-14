From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Fri, 14 Apr 2006 09:40:42 -0700
Message-ID: <20060414094042.2a36d377@localhost.localdomain>
References: <20060414134220.25554.qmail@web52903.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bridge@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FURLf-0004WV-6M
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 09:40:43 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FURLe-0002lP-UW
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 09:40:43 -0700
To: Chris Rankin <rankincj@yahoo.com>
In-Reply-To: <20060414134220.25554.qmail@web52903.mail.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Fri, 14 Apr 2006 14:42:20 +0100 (BST)
Chris Rankin <rankincj@yahoo.com> wrote:

> Hi,
> 
> I have 2 servers which are connected to a gateway machine. The gateway and one server are running
> Linux 2.6.16.2, while the third machine is running 2.6.16.5. The two ethernet ports on the gateway
> which are connected to the servers are combined into a single ethernet bridge device.
> 
> Ever since 2.6.16, I have noticed that I can no longer cross-mount the two servers' /home
> directories via UDP NFS. Which is to say that the mount command succeeds, but that trying to
> access the filesystem makes the process hang and the "NFS server not responding" message to appear
> in the console log. This is true regardless of which machine is the NFS server and which is the
> NFS client.
> 
> It all works fine if I use TCP NFS instead.
> 
> Also, UDP NFS works OK between any server and the gateway itself, so it only goes wrong when UDP
> NFS traffic is forwarded across the bridge. (I have not changed my firewall rules, which just tell
> the gateway to forward all traffic coming in from the bridge device anyway.)
> 
> Can anyone reproduce this, please? I obviously have a workaround (using TCP instead of UDP) but it
> sounds like there's a bug somewhere.
> 
> Cheers,
> Chris

Most likely the problem is that the MTU on the two devices in the bridge is different.
The bridge will silently drop packets if they are too large for the destination port (it's in the 802.1d
standard). TCP has path mtu discovery and is smart enough to recover.  UDP doesn't do
that.

Anyway don't run NFS over UDP unless you want data corruption.  There are sequence number wraparound
issues that are unsolvable when running NFS over UDP/IP and faster links.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
