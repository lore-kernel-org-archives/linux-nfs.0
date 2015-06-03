Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56920 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753322AbbFCQzU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2015 12:55:20 -0400
Date: Wed, 3 Jun 2015 12:55:18 -0400
To: Shirley Ma <shirley.ma@oracle.com>
Cc: Charles EDWARD Lever <chuck.lever@oracle.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "devesh.sharma@avagotech.com" <devesh.sharma@avagotech.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "dominique.martinet@cea.fr" <dominique.martinet@cea.fr>,
        "jeffrey.c.becker@nasa.gov" <jeffrey.c.becker@nasa.gov>,
        "rsdance@soft-forge.com" <rsdance@soft-forge.com>,
        "skc@lanl.gov" <skc@lanl.gov>,
        "sprabhu@redhat.com" <sprabhu@redhat.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "swise@opengridcomputing.com" <swise@opengridcomputing.com>,
        "wendy.cheng@intel.com" <wendy.cheng@intel.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSoRDMA bi-weekly developers meeting minutes (5/28/15)
Message-ID: <20150603165518.GB8441@fieldses.org>
References: <55675A52.1010700@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55675A52.1010700@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 28, 2015 at 11:11:30AM -0700, Shirley Ma wrote:
> NFSD workqueue mode vs. threading mode performance impacts: (Shirley)
> ---------------------------------------------------------------------
> Shirley has spent sometime test/fix/evaluating NFSD workqueue mode
> originally implemented by Jeff Layton. NFSD workqueue patchset NFSD
> workqueue modes benefit some workloads while global threading mode
> benefits some other workloads. workqueue mode is better than per-cpu
> threading mode in general. workqueue is per-cpu workqueue while global
> threading mode is not per-cpu based. There might be some room to make
> NFSD workqueue not worse than global threading mode, but this requires
> to do more in depth performance investigation work.
> 
> Feel free to reply here for anything missing or incorrect. Thanks
> everyone for joining the call and providing valuable inputs/work to
> the community to make NFSoRDMA better.

Are you planning to repost those patches to the list with a summary of
the results so far?

I don't necessarily expect that we'll have all performance problems
worked out before merging, but we do need to judge the risk that the new
threading mode never overcomes those regressions so that we're stuck
supporting both old and new threading modes indefinitely.

--b.
