From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching
	negative dentries
Date: Wed, 16 Jan 2008 18:21:09 -0500
Message-ID: <1200525669.7695.21.camel@heimdal.trondhjem.org>
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
	 <1200520574.15282.24.camel@heimdal.trondhjem.org>
	 <30593E98-7C5B-4841-94E2-40E7CD7D4857@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:59637 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756216AbYAPXVP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2008 18:21:15 -0500
In-Reply-To: <30593E98-7C5B-4841-94E2-40E7CD7D4857@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-16 at 17:09 -0500, Chuck Lever wrote:
> On Jan 16, 2008, at 4:56 PM, Trond Myklebust wrote:
> > On Wed, 2008-01-16 at 13:12 -0800, Risto Bell wrote:
> >> Already decided not to go the distance, with separate controls of
> >> time-to-live of positive and negative lookup cache entries (or is it
> >> not considered good form to overload negttl=0 as means to disable)?
> >
> > We don't have a time-to-live scheme for dentries.
> 
> Adding a TTL heuristic to dentry revalidation might help our  
> directory mtime problem.  :-)

I have a serious problem seeing how it might 'solve' anything at all.

If you're worried about correctness, then ttl is a completely useless
scheme: you can defeat it just as easily as you can defeat the mtime
resolution. The only difference is that you will eventually catch onto
the mistake, but you may have been operating on the wrong file for quite
some time before the ttl expires.
IOW: The only useful ttl values are ttl=infinity and ttl=0.

Trond

