From: <james-p@moving-picture.com>
Subject: Re: limitations at 5,8 GB?
Date: Fri, 2 Jan 2004 09:29:39 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401020929.i029TdS23123@pinatubo.mpc.local>
Cc: nuway@gmx.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AcLd9-0000gB-MW
	for nfs@lists.sourceforge.net; Fri, 02 Jan 2004 01:30:07 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AcLd9-0006Kf-CW
	for nfs@lists.sourceforge.net; Fri, 02 Jan 2004 01:30:07 -0800
To: nfs@lists.sourceforge.net
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

>im new to nfs and i googeld about this problem but i didnt find a solution for
>the following problem:
>
>I got a 100 GIG harddisk on my server and i mounted it on my client without
>any  warnings or problems. the only thing is that i now have 5.8 GB instead
>of 100. Are there any restrictions in nfs protocol, or do u know a possible
>solution for this prob?

Are you sure you have mounted the 100Gb disk over NFS?

If the 100Gb disk was not mounted on the server, then you may just be seeing
the mount point directory (e.g. a directory on the server's root disk), or you
could have exported/mounted the wrong directory?

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
