From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Allow default options in /etc/exports
Date: Wed, 7 Feb 2007 17:30:25 +1100
Message-ID: <17865.29185.322808.952798@notabene.brown>
References: <20061226225848.GA18366@uio.no>
	<17862.31691.37417.435244@notabene.brown>
	<20070205004844.GA6459@uio.no> <20070207022812.GB27634@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HEgKW-0008Mz-Ve
	for nfs@lists.sourceforge.net; Tue, 06 Feb 2007 22:30:57 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HEgKX-00024U-KK
	for nfs@lists.sourceforge.net; Tue, 06 Feb 2007 22:30:59 -0800
In-Reply-To: message from Greg Banks on Wednesday February 7
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

On Wednesday February 7, gnb@sgi.com wrote:
> 
> How about making the line the exact same syntax as normal
> lines but a pseudo export point string which is not a valid
> absolute pathname, something like "defaults".  For example:
> 
> defaults	*(rw,sync,no_subtree_check)
> /foo
> /bar		*(insecure)
> 
> could mean the same as
> 
> /foo		*(rw,sync,no_subtree_check)
> /bar		*(rw,sync,no_subtree_check,insecure)

Thats probably heading in the right direction.
That example you have given sets defaults for a particular client (or
client set).  I was imagining setting defaults for everything.
I guess both could be useful.
Global defaults could be set with

   defaults (rw,sync)

i.e. no client at all.
So if you have


default (rw,sync,no_subtree_check)
default @friends(no_root_squash)

/foo -ro,root_squash @friends()  @enemies(all_squash)

Then what options apply to a mount of /foo from a friend?
Both root_squash and no_root_squash are provided as defaults, one for
the filesystem, one for the client...

I suspect the filesystem default should rule as it is textually
closer.

> 
> There are export options which cannot usefully appear in such a
> defaults line (fsid certainly, perhaps also mountpoint=/somewhere).

Yes, we would need to be careful about that.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
