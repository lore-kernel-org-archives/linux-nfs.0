From: Kostas Georgiou <k.georgiou@imperial.ac.uk>
Subject: Re: "mount: File exists" when trying to mount a second krb5
	volume!
Date: Thu, 16 Nov 2006 15:35:28 +0000
Message-ID: <20061116153528.GA6064@imperial.ac.uk>
References: <20061116023117.36380.qmail@web58102.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkjHI-0000LX-6C
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 07:35:48 -0800
Received: from heppc218.hep.ph.ic.ac.uk ([155.198.211.218])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkjHF-0004CN-24
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 07:35:46 -0800
To: Open Source <opensource3141@yahoo.com>
In-Reply-To: <20061116023117.36380.qmail@web58102.mail.re3.yahoo.com>
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

On Wed, Nov 15, 2006 at 06:31:17PM -0800, Open Source wrote:

....

> This bug does not exist under 2.6.17 since client directories
> in /var/lib/nfs/rpc_pipefs/nfs are not reused across different
> nfsv3+krb5 mounts to the same server.

For the record I have the same problem with nfs4+krb5 in 2.6.18
so it's not just nfs3.

Kostas

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
