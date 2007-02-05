From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Please add AM_MAINTAINER_MODE to configure.in
Date: Mon, 5 Feb 2007 09:41:18 -0500
Message-ID: <4d569c330702050641s3dfd1bd0ibd3beff851c6b64f@mail.gmail.com>
References: <20070104132251.GA31023@uio.no>
	<17862.24607.837254.907122@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	nfs@lists.sourceforge.net
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HE524-0005HK-4o
	for nfs@lists.sourceforge.net; Mon, 05 Feb 2007 06:41:24 -0800
Received: from ug-out-1314.google.com ([66.249.92.169])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HE523-0001UI-Hg
	for nfs@lists.sourceforge.net; Mon, 05 Feb 2007 06:41:26 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1286547ugc
	for <nfs@lists.sourceforge.net>; Mon, 05 Feb 2007 06:41:19 -0800 (PST)
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

On 2/4/07, Neil Brown <neilb@suse.de> wrote:
> On Thursday January 4, sgunderson@bigfoot.com wrote:
> > Hi,
> >
> > Could you please add AM_MAINTAINER_MODE to configure.in? I'd like to set
> > --enable-maintainer-mode in the Debian packages (to prevent configure and
> > friends from being regenerated from possibly broken or incompatible autofoo),
> > but the macro needs to be in place in configure.in (which should probably be
> > renamed to configure.ac by now?) for the switch to exist.
>
>  From my limited reading, --enable-maintainer-mode effective negates
>  the effect of putting AM_MAINTAINER_MODE in configure.in.  So I'm
>  confused.
>
>  And there is a suggestion of that AM_MAINTAINER_MODE is a bad thing:
>
>   http://www.gnu.org/software/automake/manual/html_node/maintainer-mode.html
>
> So I need more information before I know how to proceed.

I've been working for a few weeks with this included.  As a developer
actively making changes to Makefile.am, etc., I just configure with
--enable-maintainer-mode.

I've run into the timestamp problem in the past on machines with older
versions of autoconf where the makefile thinks that autoconf needs to
be re-run.  That can be a pain.

K.C.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
