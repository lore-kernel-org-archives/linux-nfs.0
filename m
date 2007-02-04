From: Neil Brown <neilb@suse.de>
Subject: Re: Please add AM_MAINTAINER_MODE to configure.in
Date: Mon, 5 Feb 2007 09:37:19 +1100
Message-ID: <17862.24607.837254.907122@notabene.brown>
References: <20070104132251.GA31023@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDpzt-0007oF-8h
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 14:38:09 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDpza-0003Cu-8z
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 14:37:52 -0800
In-Reply-To: message from Steinar H. Gunderson on Thursday January 4
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

On Thursday January 4, sgunderson@bigfoot.com wrote:
> Hi,
> 
> Could you please add AM_MAINTAINER_MODE to configure.in? I'd like to set
> --enable-maintainer-mode in the Debian packages (to prevent configure and
> friends from being regenerated from possibly broken or incompatible autofoo),
> but the macro needs to be in place in configure.in (which should probably be
> renamed to configure.ac by now?) for the switch to exist.

 From my limited reading, --enable-maintainer-mode effective negates
 the effect of putting AM_MAINTAINER_MODE in configure.in.  So I'm
 confused.

 And there is a suggestion of that AM_MAINTAINER_MODE is a bad thing:

  http://www.gnu.org/software/automake/manual/html_node/maintainer-mode.html

So I need more information before I know how to proceed.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
