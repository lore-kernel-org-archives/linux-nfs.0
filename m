From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: NFS synchronization problems on Beowulf cluster
Date: Thu, 01 Jun 2006 13:22:48 -0400
Message-ID: <447F2268.4090401@redhat.com>
References: <loom.20060531T205740-641@post.gmane.org> <loom.20060601T155144-450@post.gmane.org> <447EF8CA.3020200@redhat.com> <loom.20060601T164005-982@post.gmane.org> <447F0E3D.9070809@redhat.com> <loom.20060601T175939-701@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FlqtC-0003Rw-Qs
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 10:23:18 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Flqt8-0004Pb-FU
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 10:23:15 -0700
To: Mario Storti <mstorti@intec.unl.edu.ar>
In-Reply-To: <loom.20060601T175939-701@post.gmane.org>
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
>>I see from the `nfsstat' output that this job mix is _very_ heavily write
>>intensive.  I might suspect that this may be contributing to the issue
>>being seen.  The consistency for files is very relaxed when those files
>>are being written to.
>>    
>>
>
>The `nfsstat' results that I sent were cumulative. I learn now that in
>theory we can zero them with `-z', but it seems not to work. Perhaps
>there is some intense traffic when the slaves boot but not at the time
>of making the `experiment'.  At that time the NFS traffic es
>_extremely_ low. We change only a small text file (for reference it's
>my ~/.bashrc) and check if the changes are reflected in the
>nodes. There are no applications running at the nodes. 
>
>  
>

I wouldn't have thought that there would be intense write activity when
the systems are booting.  I could see lots of read activity, but the
stats didn't show that much compared with the number of writes.

>>Are any special mount parameters being used?
>>    
>>
>
>No, we tried vers=2 for forcing version 2, also tried `noac'. Also
>tried `async/sync' at the server side. None had effect on the
>problem. `noac' of course reflected in a lack of efficiency, but the
>problem persists. 
>

I wouldn't think that sync/async would have any effect on this sort
of consistency.  Those options more control when the data/metadata is
actually flushed to stable storage, whether before the server responds
to the specific request or sometime after.

Can you get a raw tethereal capture file which shows the issue?  Perhaps
a capture which includes reading the original contents of the file and
then reading it again after the file is modified on the server or by
another client?  Perhaps from that we can get some clues as to where the
problem might be.

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
