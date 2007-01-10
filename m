From: Christoph Hellwig <hch@infradead.org>
Subject: Re: nfs mount problem on vxfs
Date: Wed, 10 Jan 2007 12:47:04 +0000
Message-ID: <20070110124704.GA3350@infradead.org>
References: <56800.63.119.254.10.1168372296.squirrel@mail.sonysnowie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H4crD-0006vz-OV
	for nfs@lists.sourceforge.net; Wed, 10 Jan 2007 04:47:07 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H4crD-0002Tv-NP
	for nfs@lists.sourceforge.net; Wed, 10 Jan 2007 04:47:09 -0800
To: Andrew Lee <andrew@sonysnowie.com>
In-Reply-To: <56800.63.119.254.10.1168372296.squirrel@mail.sonysnowie.com>
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

On Tue, Jan 09, 2007 at 02:51:36PM -0500, Andrew Lee wrote:
> Hi all,
> 
> I recently upgraded my redhat box to SuSE linux, the kernel version is
> 2.6.5-7.252-bigsmp
> 
> Here is my nfs server version
> 
> yast2-nfs-client-2.9.11-23.2
> yast2-nfs-server-2.9.9-23.2
> 
> I exported 2 directories, one is the /tmp on local reiserfs, and the other
> one is a /emc on vxfs (emc disk). I tried multiple nfs clients, the client
> can mount the /tmp, but none of them can mount the /emc directory, the
> client just hung.

I haven't added support for nfs exporting to the vxfs driver.  To be honest
it's quite old and didn't resource (time and actual  vxfs native systems)
to test it again.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
