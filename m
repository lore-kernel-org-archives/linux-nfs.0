From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching
	negative dentries
Date: Fri, 18 Jan 2008 16:17:04 -0500
Message-ID: <1200691024.13348.17.camel@heimdal.trondhjem.org>
References: <20080115163013.GC18911@newbie.thebellsplace.net>
	 <1200415972.7702.7.camel@heimdal.trondhjem.org>
	 <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>
	 <20080116012209.GB26010@newbie.thebellsplace.net>
	 <1200451350.28088.43.camel@heimdal.trondhjem.org>
	 <478DFD5A.1040501@RedHat.com>
	 <01AE8AF878612047A442668306EAEB05018178E7@SACEXMV01.hq.netapp.com>
	 <1200516219.6932.22.camel@heimdal.trondhjem.org>
	 <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com>
	 <20080118152902.GF7128@newbie.thebellsplace.net>
	 <16A4251B-73DA-4F2B-BA86-6A5890CC727B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:59392 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760633AbYARVSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 16:18:04 -0500
In-Reply-To: <16A4251B-73DA-4F2B-BA86-6A5890CC727B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-18 at 16:12 -0500, Chuck Lever wrote:

> When would anyone want to use lookupcache=none -- what exactly would  
> it do?  How is it different than actimeo=0?

It would be very different. The idea of lookupcache=none would be to
turn off the directory mtime-based revalidation algorithm in
nfs_lookup_revalidate().
IOW: you would force an on-the-wire LOOKUP call for each dentry
revalidation.

Cheers
  Trond

