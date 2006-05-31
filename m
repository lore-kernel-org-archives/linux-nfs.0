From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Problems with fh_fsid_type=3 exports (device minor id >
	255)
Date: Wed, 31 May 2006 15:48:39 -0700
Message-ID: <1149115719.12795.49.camel@dyn9047022153>
References: <1148669319.12795.44.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FlZS2-0005kf-S7
	for nfs@lists.sourceforge.net; Wed, 31 May 2006 15:46:06 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FlZS2-00024Q-OP
	for nfs@lists.sourceforge.net; Wed, 31 May 2006 15:46:06 -0700
Received: from e33.co.us.ibm.com ([32.97.110.151])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FlZS0-0003I8-Hv
	for nfs@lists.sourceforge.net; Wed, 31 May 2006 15:46:06 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4VMjCdQ020354
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <nfs@lists.sourceforge.net>; Wed, 31 May 2006 18:45:12 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k4VMjCxw156906
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Wed, 31 May 2006 16:45:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4VMjBa6016932
	for <nfs@lists.sourceforge.net>; Wed, 31 May 2006 16:45:12 -0600
To: NFS List <nfs@lists.sourceforge.net>, Neil Brown <neilb@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1148669319.12795.44.camel@dyn9047022153>
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

On Fri, 2006-05-26 at 11:48 -0700, Frank Filz wrote:
> I having a problem with the 2.6.9 kernel and mounting file systems with
> a minor device id > 255 where the mount fails. It seems like the file
> handle is never cached. We are able to proceed if fsid is specified
> in /etc/exports. nfs-utils version is 1.0.6.
> 
> Have others seen this problem and is there a fix in a later kernel?
> 
> I've been trying to follow the fh_compose and fh_verify code to
> understand this, but I don't see where there's a difference between type
> 3 file handles and type 1 file handles (fsid specified in /etc/exports)
> that could cause a problem. When I add a little bit of debug messages, I
> see that expkey_parse is being called as a result of a system call for
> the type 1 handles, but not for the type 3 handles.

I've trudged my way through the code, and I think I've found the
problem. The problem seems to be the way the kernel and nfs-utils expect
the fsid to be coded. The kernel uses this code to encode:

	unsigned major = MAJOR(dev);
	unsigned minor = MINOR(dev);
	return (minor & 0xff) | (major << 8) | ((minor & ~0xff) << 12);

The user space uses this code to decode:

		memcpy(&dev, fsid, 4);
		memcpy(&inode, fsid+4, 4);
		major = (dev & 0xfff00) >> 8;
		minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);

I think when the entry is exported into the kernel, the fsid is also
going to be wrong.

The question I have is should I fix this in the kernel or in nfs-utils?

Thanks

Frank Filz




-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
