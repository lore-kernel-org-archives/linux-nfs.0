From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Fri, 14 Apr 2006 14:00:34 -0700
Message-ID: <20060414140034.2fd7100c@localhost.localdomain>
References: <20060414135321.53e60516@dxpl.pdx.osdl.net>
	<20060414205815.15338.qmail@web52911.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bridge@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUVPD-0006LS-8k
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 14:00:39 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FUVPB-00060I-Kr
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 14:00:39 -0700
To: Chris Rankin <rankincj@yahoo.com>
In-Reply-To: <20060414205815.15338.qmail@web52911.mail.yahoo.com>
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

On Fri, 14 Apr 2006 21:58:15 +0100 (BST)
Chris Rankin <rankincj@yahoo.com> wrote:

> --- Stephen Hemminger <shemminger@osdl.org> wrote:
> > What is the mtu of eth0 and eth1 on the bridge?
> 
> 1500 on both eth0 and eth1, and on the actual bridge device too.

Are you doing brouting or filtering? or vlan's?
Are the ethernet devices on the bridge doing hardware checksumming?
What version of kernel and configuration are running on the bridge?


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
