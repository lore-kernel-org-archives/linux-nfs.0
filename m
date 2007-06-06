From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.21.3: NFS: Buggy server - nlink == 0!
Date: Wed, 06 Jun 2007 08:27:42 -0400
Message-ID: <1181132862.6171.2.camel@heimdal.trondhjem.org>
References: <20070606081303.GB7168@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hvuc7-0004Nn-5P
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 05:27:47 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18lySm/l5wZKakWuyabYRa3NwV7SDNst2c=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hvuc8-0000tU-FU
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 05:27:50 -0700
In-Reply-To: <20070606081303.GB7168@localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The server is returning a deleted file to the client as the result of a
lookup() call. I'd call that a server bug.

Trond


On Wed, 2007-06-06 at 01:13 -0700, Ravikiran G Thirumalai wrote:
> While running a dbench stress test on  a nfs mounted file system, I notice
> the subject error message on the client machine.  The client machine is a 48
> core box with NUMA characteristics and 1024 dbench processes running
> continuously in a loop, while another memory hog application runs in parallel.
> The client is on 2.6.21.3.  The server is booted up with 2.6.21.3 as well.
> Attached is the server configuration.  Same test on a 2.6.16 client does not
> spew out these messages.  Is this really the server issue, or is the NFS
> client to be blamed here?
> 
> fstab on the client goes as:
> vus2:/mnt/sda5          /nfstest                nfs  udp,wsize=32768,rsize=32768 0 0
> 
> /etc/exports on the server looks like:
> /mnt/sda5 *(rw,no_root_squash,sync)
> 
> I will be happy to post full config/dmesg if required.
> 
> The client side NFS config goes as:
> #
> # Network File Systems
> #
> CONFIG_NFS_FS=y
> CONFIG_NFS_V3=y
> # CONFIG_NFS_V3_ACL is not set
> # CONFIG_NFS_V4 is not set
> CONFIG_NFS_DIRECTIO=y
> CONFIG_NFSD=y
> CONFIG_NFSD_V3=y
> # CONFIG_NFSD_V3_ACL is not set
> # CONFIG_NFSD_V4 is not set
> CONFIG_NFSD_TCP=y
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_EXPORTFS=y
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=y
> # CONFIG_RPCSEC_GSS_KRB5 is not set
> # CONFIG_RPCSEC_GSS_SPKM3 is not set
> 
> The server side NFS config goes as:
> 
> #
> # Network File Systems
> #
> CONFIG_NFS_FS=m
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> # CONFIG_NFS_V4 is not set
> CONFIG_NFS_DIRECTIO=y
> CONFIG_NFSD=m
> CONFIG_NFSD_V2_ACL=y
> CONFIG_NFSD_V3=y
> CONFIG_NFSD_V3_ACL=y
> CONFIG_NFSD_V4=y
> CONFIG_NFSD_TCP=y
> CONFIG_LOCKD=m
> CONFIG_LOCKD_V4=y
> CONFIG_EXPORTFS=m
> CONFIG_NFS_ACL_SUPPORT=m
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=m
> 
> Thanks,
> Kiran
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
