From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] Allow default options in /etc/exports
Date: Wed, 7 Feb 2007 13:28:12 +1100
Message-ID: <20070207022812.GB27634@sgi.com>
References: <20061226225848.GA18366@uio.no>
	<17862.31691.37417.435244@notabene.brown>
	<20070205004844.GA6459@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HEcY5-0002KH-MS
	for nfs@lists.sourceforge.net; Tue, 06 Feb 2007 18:28:41 -0800
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HEcY6-0005KY-CD
	for nfs@lists.sourceforge.net; Tue, 06 Feb 2007 18:28:43 -0800
In-Reply-To: <20070205004844.GA6459@uio.no>
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

On Mon, Feb 05, 2007 at 01:48:44AM +0100, Steinar H. Gunderson wrote:
> On Mon, Feb 05, 2007 at 11:35:23AM +1100, Neil Brown wrote:
> > I would like to have system-wide defaults too (as you mention).  Any
> > suggestions on syntax?  Having
> > 
> > -sync,no_root_squash,no_subtree_check
> > 
> > would be syntactically consistent (which is good) but is kind-a ugly.
> 
> My first hunch is to put it on the command line (so one could have it in
> /etc/default/nfs-common), but I realize that would be confusing (and possibly
> different across distributions, and less flexible). I'm a bit short on good
> syntax suggestions apart from that, really -- adding a different kind of line
> sounds a bit like opening a can of worms syntax-wise...

How about making the line the exact same syntax as normal
lines but a pseudo export point string which is not a valid
absolute pathname, something like "defaults".  For example:

defaults	*(rw,sync,no_subtree_check)
/foo
/bar		*(insecure)

could mean the same as

/foo		*(rw,sync,no_subtree_check)
/bar		*(rw,sync,no_subtree_check,insecure)

There are export options which cannot usefully appear in such a
defaults line (fsid certainly, perhaps also mountpoint=/somewhere).

Greg.
-- 
Greg (not Dave) Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
