From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Debian, SIGPIPE, "libnfsidmap", and init.d vs. umount
Date: Mon, 6 Dec 2004 11:34:47 +1100
Message-ID: <16819.43303.95619.661063@cse.unsw.edu.au>
References: <20041204221504.GD6146@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cb6qA-0006YS-7k
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 16:34:58 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cb6q9-0007ek-CW
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 16:34:58 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Saturday December 4
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

On Saturday December 4, chip@pobox.com wrote:
> Debian needs a bugfix release of nfs-utils, because of the SIGPIPE
> bug.  This being my job, I figured I could grab the HEAD version of
> nfs-utils.  And since the Debian sarge release is coming up soon (no,
> really), I hoped I'd find something unlikely to crash; instead I'm
> having difficulty with the build.

I use "./configure --disable-nfsv4 --disable-gss"  but you might not
want to...

> 
> I gather that "libnfsidmap" is what I'll find in:
> 
>   http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/
> 
> Is there some reason this hasn't been made part of Debian already,
> seeing as how it already contains Debian build infrastructure?

Probably just the lack of a certified debian developer to do it, but
I'll let Bruce Fields answer further..

> 
> Also, is it a bug or a feature that the NFS startup scripts know how
> to mount special-purpose filesystems, but not unmount them?

A feature(?).

There is a need to mount, but no need to unmount.

It is a lot like there being a "modprobe" but no "rmmod".

NeilBrown


> -- 
> Chip Salzenberg              - a.k.a. -           <chip@pobox.com>
> People are supposed to die for freedom.  Not the other way around.
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now. 
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
