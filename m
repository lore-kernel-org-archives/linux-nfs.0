From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH] remove unneeded ext2 include from nfsd
Date: Mon, 14 Feb 2005 10:33:00 +0100
Message-ID: <20050214093300.GA15790@suse.de>
References: <20050213155257.GA21488@suse.de> <20050214093142.GA23861@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D0cbH-000301-9b
	for nfs@lists.sourceforge.net; Mon, 14 Feb 2005 01:33:03 -0800
Received: from mail.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D0cbG-0000oS-Ly
	for nfs@lists.sourceforge.net; Mon, 14 Feb 2005 01:33:03 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050214093142.GA23861@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

 On Mon, Feb 14, Olaf Kirch wrote:

> On Sun, Feb 13, 2005 at 04:52:57PM +0100, Olaf Hering wrote:
> > nfs3proc.c includes ext2 headers for some constants, strange.
> 
> It used to be that nfsd accessed the ext2 inode generation number
> directly, that's where the include came from, probably.

It looks for ext2/ext3 and msdos magic to tweak some settings.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
