From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: NFSv4  and vi
Date: Thu, 19 Feb 2004 18:00:44 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402191800.44193.vincent.roqueta@ext.bull.net>
References: <200402190958.38127.vincent.roqueta@ext.bull.net> <20040219154936.GA20586@fieldses.org>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Atra1-0000RP-QM
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 09:03:17 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtrMY-0002We-1K
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 08:49:22 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040219154936.GA20586@fieldses.org>
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

Le Jeudi 19 F=E9vrier 2004 16:49, J. Bruce Fields a =E9crit :
> On Thu, Feb 19, 2004 at 09:58:38AM +0100, Vincent ROQUETA wrote:
> > Here are vi traces for opening "/mnt/nfs/vincent/suite-tests/toto3"
>
> These bug reports are no help if you won't remind us, on each bug
> report, which kernel you're using, with which (if any) patches.  Also,
> it'd help if you could test with the latest CITI NFSv4 patches
> (http://www.citi.umich.edu/projects/nfsv4/linux/).  I suspect the
> problem you're seeing is a problem that's already fixed with those
> patches.
>
> --Bruce Fields
>

The problem still appear with kernel 2.6.2 and all patches.
(Linux roquetav 2.6.2-CITI_NFS4_ALL-1)




-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
