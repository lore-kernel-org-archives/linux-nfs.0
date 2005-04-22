From: Bradford Arrington <brada@cadence.com>
Subject: Re: default nfs mount options from linux to linux
Date: Fri, 22 Apr 2005 09:36:06 -0700
Message-ID: <1114187766.6702.6.camel@localhost>
References: <OF05A65FF9.8E6B5618-ON88256FEB.00566EB2-88256FEB.0056BCC7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DP18z-00088G-Ix
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 09:36:41 -0700
Received: from mailgate2.cadence.com ([158.140.2.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DP18y-0005iE-QR
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 09:36:41 -0700
To: Bruce Allan <bruce.allan@us.ibm.com>
In-Reply-To: <OF05A65FF9.8E6B5618-ON88256FEB.00566EB2-88256FEB.0056BCC7@us.ibm.com>
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

Bruce,

First thank you to all who replied. 

It turns out I should have just looked at the source code to the mount
command found in utils-linux tar package.

It seems that although it may look like its mount with 8k r/wsize, the
mount C code says it is automatically changed by the kernel it self when
needed.

This explains a lot because if I where to just mount it with 8k r/wsizes
the performance is slower than if I where to just mount linux to linux
with out any options (i.e. mount linxnfs:/export /mnt). 
These seem to be the initial defaults :
nfs rw,v3,rsize=8192,wsize=8192,hard,udp,lock

However this does not work with Solaris 10, in order to get higher
throughput speeds you must specify 8k r/wsizes 

-Brad

On Fri, 2005-04-22 at 08:47 -0700, Bruce Allan wrote:
> Mount the volume without options and check /proc/mounts.  Note that some 
> options may differ based on negotiation with the server.
> 
> Regards,
> ---
> Bruce Allan  <bruce.allan@us.ibm.com>
> Software Engineer, Linux Technology Center
> IBM Corporation, Beaverton OR USA
> 503-578-4187   IBM Tie-line 775-4187
> 
> 
> 
> 
> Bradford Arrington <brada@cadence.com> 
> Sent by: nfs-admin@lists.sourceforge.net
> 04/21/2005 06:01 PM
> 
> To
> nfs@lists.sourceforge.net
> cc
> 
> Subject
> [NFS] default nfs mount options from linux to linux
> 
> 
> 
> 
> 
> 
> 
> Does anyone know what or how to find the default mount option are when
> mounting an nfs volume?
> example
> mount linuxnfs:/export /mnt 
> 
> How do I find the rsize/wsize and any other options? (that are default)
> 
> I am lead to believe that the nfs man page information is false for
> r/wsize 1k (no way) (udp default is correct though). If I set the
> r/wsize to 1k performance is very slow. In a "vanilla" default as above
> it has the fastest iozone benchmarks.
> 
> Thanks,
> -Brad
> 
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
