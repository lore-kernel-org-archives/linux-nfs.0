From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: [Bridge] Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Mon, 17 Apr 2006 23:09:15 +0100 (BST)
Message-ID: <20060417220915.38858.qmail@web52908.mail.yahoo.com>
References: <4443DD74.80101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Stephen Hemminger <shemminger@osdl.org>,
	nfs@lists.sourceforge.net, bridge@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVbuO-0007pg-SU
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 15:09:24 -0700
Received: from web52908.mail.yahoo.com ([206.190.49.18])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FVbuL-0006Zf-Op
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 15:09:24 -0700
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4443DD74.80101@trash.net>
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

--- Patrick McHardy <kaber@trash.net> wrote:
> >>[patch 06/22] NETFILTER: Fix fragmentation issues with bridge netfilt=
er

Thanks, this patch fixes the "NFS via UDP" problem.

Cheers,
Chris



	=09
___________________________________________________________=20
Yahoo! For Good - Sponsor a London Marathon runner - http://uk.promotions=
.yahoo.com/charity/london-marathon


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
