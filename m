From: Neil Horman <nhorman@redhat.com>
Subject: Re: SMP, NFS, and 2.6
Date: Tue, 29 Mar 2005 16:13:24 -0500
Message-ID: <20050329211324.GK22447@hmsendeavour.rdu.redhat.com>
References: <111aefd050329125848955802@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGO1f-0005wV-0T
	for nfs@lists.sourceforge.net; Tue, 29 Mar 2005 13:13:27 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DGO1e-0000Az-F9
	for nfs@lists.sourceforge.net; Tue, 29 Mar 2005 13:13:26 -0800
To: penney@msu.edu
In-Reply-To: <111aefd050329125848955802@mail.gmail.com>
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

On Tue, Mar 29, 2005 at 03:58:02PM -0500, Chris Penney wrote:
> I've heard from some (via google searchs) that there are issues with
> NFS + SMP when using the 2.6 kernel.  Assuming I'm using 2.6.11.5 w/
> the NFS-ALL patches applied should I be concerned about running SMP
> (dual cpu pentium 4 doing pretty much only NFSv3 TCP, but looking
> toward NFSv4)?
> 
> Assuming it's ok to use SMP on a heavy use NFS server, should I enable
> or disable hyperthreading?  I'd assume that for NFS hyperthreading
> would be good, but that's only a guess.
> 
> Thanks,
> 
>    Chris
> 
Are you referring to the dcache problems with XFS?  I think it was only a
problem when the NFS server was exporting an XFS file system.  I also haven't
checked in some time, but I believe those problems have since been fixed.

Neil

> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
