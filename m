From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: NFS synchronization problems on Beowulf cluster
Date: Thu, 01 Jun 2006 11:56:45 -0400
Message-ID: <447F0E3D.9070809@redhat.com>
References: <loom.20060531T205740-641@post.gmane.org> <loom.20060601T155144-450@post.gmane.org> <447EF8CA.3020200@redhat.com> <loom.20060601T164005-982@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FlpXb-00042c-SY
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 08:56:55 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FlpXb-0003yL-OT
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 08:56:55 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FlpXa-0004ch-KJ
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 08:56:55 -0700
To: Mario Storti <mstorti@intec.unl.edu.ar>
In-Reply-To: <loom.20060601T164005-982@post.gmane.org>
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

Mario Storti wrote:

>Peter Staubach <staubach <at> redhat.com> writes:
>
>  
>
>>What is the local file system type being exported on the NFS servers?
>>    
>>
>
>It is software RAID mounted on top of XFS. At first time we suspected
>of this combination, and the first thing we do is to clone the system
>on a plain ext3 filesystem without RAID. The cloned cluster with two
>nodes exhibited exactly the same behaviour, so we don't think now that
>the problem is in the combination of NFS with RAID+XFS. It ssems to be
>something in the NFS setup/configuration itself.
>

I see.

I see from the nfsstat output that this job mix is _very_ heavily write
intensive.  I might suspect that this may be contributing to the issue
being seen.  The consistency for files is very relaxed when those files
are being written to.

Are any special mount parameters being used?

    Thanx...

       ps


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
