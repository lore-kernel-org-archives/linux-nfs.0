From: Neil Brown <neilb@suse.de>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Fri, 13 Apr 2007 11:39:48 +1000
Message-ID: <17950.57188.878877.547112@notabene.brown>
References: <17950.44333.118970.276558@notabene.brown>
	<200704122055.12223.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcAlZ-0000OI-BD
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 18:39:57 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HcAlZ-0000qA-W1
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 18:39:59 -0700
In-Reply-To: message from Mike Frysinger on Thursday April 12
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday April 12, vapier@gentoo.org wrote:
> On Thursday 12 April 2007, Neil Brown wrote:
> > mountd/statd currently bind to privileged ports to listen for
> > requests.
> >
> > This is really a bad thing to do as there is no range of privilege
> > ports that is guaranteed not to be assigned to some service.
> 
> s/privilege// ... you have the same problem regardless of privilege state ... 
> svn/mysql/postgresql/etc... can be just as troublesome for people

There are supposed to be some ranges which are never assigned.
According to
  http://www.iana.org/assignments/port-numbers

    DYNAMIC AND/OR PRIVATE PORTS

    The Dynamic and/or Private Ports are those from 49152 through 65535

as long as we choose one of those (and that is what happens if you
just let the kernel decide for you) there must be no conflict.

> 
> if that's true, then we could at least rewrite the socket code to bind to 
> ports that do not appear in /etc/services (via getservbyport()) ... that'd 
> allow admins to easily prevent things like mountd/statd from hijacking 
> reserved ports ...

I had thought of that too.  I'll probably implement it.  Your code (in
subsequent email) is a little more complicated than needed.  Just
repeatedly call bindresvport, closing if you don't like it.  The port
number tried increments each time.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
