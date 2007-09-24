From: Neil Brown <neilb@suse.de>
Subject: Re: Bug#443591: nfs-kernel-server: Unexporting
	directories	no	longer working
Date: Mon, 24 Sep 2007 16:58:45 +1000
Message-ID: <18167.24613.796605.199161@notabene.brown>
References: <20070922174231.11200.29119.reportbug@localhost.localdomain>
	<20070923000102.GA29785@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Liontooth <liontooth@cogweb.net>,
	nfs@lists.sourceforge.net, 443591@bugs.debian.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZhu7-0005MT-JI
	for nfs@lists.sourceforge.net; Sun, 23 Sep 2007 23:58:51 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZhuC-00035U-Bd
	for nfs@lists.sourceforge.net; Sun, 23 Sep 2007 23:58:56 -0700
In-Reply-To: message from Steinar H. Gunderson on Sunday September 23
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sunday September 23, sgunderson@bigfoot.com wrote:
> On Sat, Sep 22, 2007 at 10:42:31AM -0700, David Liontooth wrote:
> > Package: nfs-kernel-server
> > Version: 1:1.1.0-13
> > Severity: normal
> > 
> > 
> > The command to unexport a directory appears to no longer have any effect.
> > 
> > I issue "exportfs -u :/tv01" and "exportfs" shows /tv01 still exported; consequently, I cannot unmount it.
> > In contrast, removing /tv01 from /etc/exports and then running exportfs -ra successfully removes the export.
> > 
> > This used to work fine.
> 
> Sending this on to upstream, as I cannot see any good reason offhand why it
> should not work.

Some simple testing and code review suggests that this works as
expected.  However it is possible that I am expecting something
different to you, or testing something different.

You say you:
    exportfs -u :/tv01

What exactly is in your /etc/exports that this is expected to revert?
The obvious answer would be

    /tv01  (some,flags,here)

however "exportfs" will complain about that, so I suspect not.

Maybe you have:

    /tv01 somehost(someflags)  otherhost(otherflags)

and you expect
    exportfs -u :/tv01

to unexport /tv01 to all hosts?  I would agree that doesn't work.  Did
it ever?  What version?

As an aside, you can always:
   exportfs -f
and then unmount filesystems.  They will be free to be unmounted until
the next NFS access request arrives.  Maybe that will server your
needs?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
