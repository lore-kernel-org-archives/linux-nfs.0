From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Please add AM_MAINTAINER_MODE to configure.in
Date: Mon, 5 Feb 2007 00:45:55 +0100
Message-ID: <20070204234555.GA6139@uio.no>
References: <20070104132251.GA31023@uio.no>
	<17862.24607.837254.907122@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDr4A-0006WT-HZ
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 15:46:39 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDr4C-0001YZ-40
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 15:46:40 -0800
In-Reply-To: <17862.24607.837254.907122@notabene.brown>
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

On Mon, Feb 05, 2007 at 09:37:19AM +1100, Neil Brown wrote:
>  From my limited reading, --enable-maintainer-mode effective negates
>  the effect of putting AM_MAINTAINER_MODE in configure.in.  So I'm
>  confused.

AM_MAINTAINER_MODE simply puts the option in there. The default doesn't
change AFAICS.

>  And there is a suggestion of that AM_MAINTAINER_MODE is a bad thing:
> 
>   http://www.gnu.org/software/automake/manual/html_node/maintainer-mode.html
> 
> So I need more information before I know how to proceed.

It is primarily useful for packagers. I need to know that my package builds
the same regardless of what's on the system (except for dependencies, of
course) -- by default the builds break if the user has autoconf installed but
none of the other dependencies. (As most of our builds are done fully
automated, there's simply no such control, unless I go to great lengths to
annoy users.) --enable-maintainer-mode simply removes all the magic from the
build and gives the builder control -- which is useful for a distribution
packager, but perhaps less so for a developer.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
