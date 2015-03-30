Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:59081 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753101AbbC3SBT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 14:01:19 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>
Cc: "'linux-rdma'" <linux-rdma@vger.kernel.org>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        "Veeresh U. Kokatnur" <veereshuk@chelsio.com>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net> <55195B3B.40205@opengridcomputing.com> <9D560F87-71BF-470E-B411-EF68D75070AA@oracle.com>
In-Reply-To: <9D560F87-71BF-470E-B411-EF68D75070AA@oracle.com>
Subject: RE: [PATCH v2 00/15] NFS/RDMA patches proposed for 4.1
Date: Mon, 30 Mar 2015 13:01:20 -0500
Message-ID: <029301d06b13$86ec05f0$94c411d0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Veeresh U. Kokatnur <veereshuk@chelsio.com>


> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Monday, March 30, 2015 12:53 PM
> To: Steve Wise
> Cc: linux-rdma; Linux NFS Mailing List
> Subject: Re: [PATCH v2 00/15] NFS/RDMA patches proposed for 4.1
> 
> 
> On Mar 30, 2015, at 10:18 AM, Steve Wise <swise@opengridcomputing.com> wrote:
> 
> > Hey Chuck,
> >
> > Chelsio's QA regression tested this series on iw_cxgb4.  Tests out good.
> >
> > Tests ran: spew, ffsb, xdd, fio, dbench, and cthon with both v3 and v4.
> 
> Thanks, Steve. Who should I credit in the Tested-by tag?
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 


