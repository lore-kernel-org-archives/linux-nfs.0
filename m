From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH 0 / 1] Move NFS mount code from
	util-linux	to	nfs-utils - take2
Date: Thu, 15 Jun 2006 10:41:38 -0700
Message-ID: <1150393298.3565.2.camel@dyn9047022153>
References: <448DF279.8090005@redhat.com>  <44918BDD.2C84.006B.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FqvqP-0000KX-Ox
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 10:41:25 -0700
Received: from e35.co.us.ibm.com ([32.97.110.153])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FqvqO-0001Ov-MY
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 10:41:26 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e35.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k5FHfDBJ012331
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <nfs@lists.sourceforge.net>; Thu, 15 Jun 2006 13:41:13 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k5FHewI6285060
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 15 Jun 2006 11:40:58 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k5FHfDK9004291
	for <nfs@lists.sourceforge.net>; Thu, 15 Jun 2006 11:41:13 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k5FHfCtZ004246
	for <nfs@lists.sourceforge.net>; Thu, 15 Jun 2006 11:41:12 -0600
To: NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <44918BDD.2C84.006B.0@novell.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-06-15 at 05:10 -0600, Chakravarthi P wrote:
> +			break;
> +		case 't':
> +			nfs_mount_vers = (strncmp(optarg, "nfs4", 4)) ?
> 0 : 4;
> +			break;
> 
> 2.  i dont think a -t option makes sense for mount.nfs  
>      mount.nfs itself says it is a nfs file system
>      you can pick up the version from -o nfsvers=4  to cater to nfs
> version
>      -t is by legacy meant for specifying the filesystem type.

-t nfs4 is required for compatibility with existing scripts
and /etc/fstab entries.

Frank




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
