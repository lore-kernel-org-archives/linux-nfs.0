From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching
	negative dentries
Date: Wed, 16 Jan 2008 16:56:14 -0500
Message-ID: <1200520574.15282.24.camel@heimdal.trondhjem.org>
References: <20080115163013.GC18911@newbie.thebellsplace.net>
	 <1200415972.7702.7.camel@heimdal.trondhjem.org>
	 <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>
	 <20080116012209.GB26010@newbie.thebellsplace.net>
	 <1200451350.28088.43.camel@heimdal.trondhjem.org>
	 <478DFD5A.1040501@RedHat.com>
	 <01AE8AF878612047A442668306EAEB05018178E7@SACEXMV01.hq.netapp.com>
	 <1200516219.6932.22.camel@heimdal.trondhjem.org>
	 <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com>
	 <478E7345.8080003@cypress.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Risto Bell <reb-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46258 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313AbYAPV4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2008 16:56:19 -0500
In-Reply-To: <478E7345.8080003-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-16 at 13:12 -0800, Risto Bell wrote:
> Already decided not to go the distance, with separate controls of
> time-to-live of positive and negative lookup cache entries (or is it
> not considered good form to overload negttl=0 as means to disable)?

We don't have a time-to-live scheme for dentries. When deciding whether
we need to revalidate the lookup, we check the parent directory mtime,
and see if the directory contents have changed since the last
revalidation.

Trond

