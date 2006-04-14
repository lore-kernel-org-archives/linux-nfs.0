From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Fri, 14 Apr 2006 23:13:12 +0100 (BST)
Message-ID: <20060414221312.64298.qmail@web52901.mail.yahoo.com>
References: <20060414140034.2fd7100c@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: bridge@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUWXv-0005Jc-At
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 15:13:43 -0700
Received: from web52901.mail.yahoo.com ([206.190.49.11])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FUWXq-0004gU-TB
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 15:13:40 -0700
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060414140034.2fd7100c@localhost.localdomain>
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

--- Stephen Hemminger <shemminger@osdl.org> wrote:
> Are you doing brouting or filtering? or vlan's?
> Are the ethernet devices on the bridge doing hardware checksumming?
> What version of kernel and configuration are running on the bridge?

The gateway is running 2.6.16.2, and all its ethernet devices are e100s. =
They might well do
hardware checksumming, but the configuration used to work fine. There is =
no brouting / ebfilters,
and I don't think that there's any vlan either (on the basis that I can't=
 have it if I don't know
what it is ;-).)

Cheers,
Chris



=09
=09
	=09
___________________________________________________________=20
Yahoo! Messenger - NEW crystal clear PC to PC calling worldwide with voic=
email http://uk.messenger.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
