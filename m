From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Fri, 14 Apr 2006 15:17:45 -0700
Message-ID: <20060414151745.062981e0@localhost.localdomain>
References: <20060414140034.2fd7100c@localhost.localdomain>
	<20060414221312.64298.qmail@web52901.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bridge@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUWbw-0005hu-Fw
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 15:17:52 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FUWbv-0006DE-Mp
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 15:17:52 -0700
To: Chris Rankin <rankincj@yahoo.com>
In-Reply-To: <20060414221312.64298.qmail@web52901.mail.yahoo.com>
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

On Fri, 14 Apr 2006 23:13:12 +0100 (BST)
Chris Rankin <rankincj@yahoo.com> wrote:

> --- Stephen Hemminger <shemminger@osdl.org> wrote:
> > Are you doing brouting or filtering? or vlan's?
> > Are the ethernet devices on the bridge doing hardware checksumming?
> > What version of kernel and configuration are running on the bridge?
> 
> The gateway is running 2.6.16.2, and all its ethernet devices are e100s. They might well do
> hardware checksumming, but the configuration used to work fine. There is no brouting / ebfilters,
> and I don't think that there's any vlan either (on the basis that I can't have it if I don't know
> what it is ;-).)
> 

If you have the patience, then "git bisect" will pin down the regression.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
