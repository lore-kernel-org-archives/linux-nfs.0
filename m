From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Bug#443591: nfs-kernel-server: Unexporting directories
	no	longer working
Date: Sun, 23 Sep 2007 02:01:02 +0200
Message-ID: <20070923000102.GA29785@uio.no>
References: <20070922174231.11200.29119.reportbug@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: David Liontooth <liontooth@cogweb.net>, 443591@bugs.debian.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZEud-0003jZ-5s
	for nfs@lists.sourceforge.net; Sat, 22 Sep 2007 17:01:29 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZEuZ-0004gu-4i
	for nfs@lists.sourceforge.net; Sat, 22 Sep 2007 17:01:26 -0700
In-Reply-To: <20070922174231.11200.29119.reportbug@localhost.localdomain>
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

On Sat, Sep 22, 2007 at 10:42:31AM -0700, David Liontooth wrote:
> Package: nfs-kernel-server
> Version: 1:1.1.0-13
> Severity: normal
> 
> 
> The command to unexport a directory appears to no longer have any effect.
> 
> I issue "exportfs -u :/tv01" and "exportfs" shows /tv01 still exported; consequently, I cannot unmount it.
> In contrast, removing /tv01 from /etc/exports and then running exportfs -ra successfully removes the export.
> 
> This used to work fine.

Sending this on to upstream, as I cannot see any good reason offhand why it
should not work.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
