From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: NFS synchronization problems on Beowulf cluster
Date: Thu, 01 Jun 2006 10:25:14 -0400
Message-ID: <447EF8CA.3020200@redhat.com>
References: <loom.20060531T205740-641@post.gmane.org> <loom.20060601T155144-450@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Flo84-0003Qg-Ek
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 07:26:28 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Flo83-0003n0-VZ
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 07:26:28 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Flo81-0004FJ-Vb
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 07:26:27 -0700
To: Mario Storti <mstorti@intec.unl.edu.ar>
In-Reply-To: <loom.20060601T155144-450@post.gmane.org>
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

>Mario Storti <mstorti <at> intec.unl.edu.ar> writes:
>
>  
>
>>We have a Beowulf class cluster built on Linux Fedora Core 3 (kernel
>>2.6.15). The cluster is disk-less (nodes don't have hard disks) based
>>on the Warewulf package. NFS traffic is reduced by using VNFS
>>filesystems at the nodes.
>>
>>We found something strange related with NFS. For some files in user
>>accounts if we make some modifications to the file in the server, this
>>changes are not seen in the compute nodes. The NFS server is NFS3 and
>>with the standard configuration (8 instances of the server and default
>>parameters). The cluster has 20 nodes at this time, but we have made
>>experiments with a `cloned' cluster and even with only two nodes the
>>problem persist. 
>>    
>>
>
>I see now that perhaps my reference to VNFS is somewhat obscure. VNFS
>is basically a RAM disk at the nodes (in our case of size 50MB
>approx.) with typically `light' directories /etc, /bin, /lib... 
>
>http://www.warewulf-cluster.org/cgi-bin/trac.cgi/wiki/VNFS
>
>The `heavy' directories like /usr and /home are exported via standard
>NFS, so that the VNFS issue is not directly related with the problem. 
>
>On the other hand we tried to switch to NFS version 2 and the problem 
>persists. 
>

What is the local file system type being exported on the NFS servers?

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
