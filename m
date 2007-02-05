From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH] Allow default options in /etc/exports
Date: Mon, 5 Feb 2007 01:48:44 +0100
Message-ID: <20070205004844.GA6459@uio.no>
References: <20061226225848.GA18366@uio.no>
	<17862.31691.37417.435244@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDs2t-00043z-HC
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 16:49:23 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDs2u-0007vd-65
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 16:49:25 -0800
In-Reply-To: <17862.31691.37417.435244@notabene.brown>
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

On Mon, Feb 05, 2007 at 11:35:23AM +1100, Neil Brown wrote:
>> [Cc-on-reply, please]
> Always.... doesn't everybody?

Not always. I tried subscribing to the list, but it doesn't seem like it
worked, for some reason -- odd. SourceForge is not always my friend, although
you'd believe it would be hard to go wrong with Mailman...

> I would like to have system-wide defaults too (as you mention).  Any
> suggestions on syntax?  Having
> 
> -sync,no_root_squash,no_subtree_check
> 
> would be syntactically consistent (which is good) but is kind-a ugly.

My first hunch is to put it on the command line (so one could have it in
/etc/default/nfs-common), but I realize that would be confusing (and possibly
different across distributions, and less flexible). I'm a bit short on good
syntax suggestions apart from that, really -- adding a different kind of line
sounds a bit like opening a can of worms syntax-wise...

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
