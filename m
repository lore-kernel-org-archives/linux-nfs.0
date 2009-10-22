From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/5] nfsd: Fix independence of a few nfsd related
 headers
Date: Wed, 21 Oct 2009 20:28:18 -0400
Message-ID: <1256171298.6809.1.camel@heimdal.trondhjem.org>
References: <4ADEC1EF.8040107@panasas.com>
	 <1256112873-32495-1-git-send-email-bharrosh@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36250 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbZJVA2P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2009 20:28:15 -0400
In-Reply-To: <1256112873-32495-1-git-send-email-bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-10-21 at 10:14 +0200, Boaz Harrosh wrote:
> An header should be compilation independent, .i.e pull in
> any header who's declarations are directly used by this header.
> And not let users re-include all it's dependencies all over
> again.
> 
> [At the end of the day what's the use of a header if it does
>  not have more then one user?]


The problem with this is that you quickly end up including the same
header files over and over and over again as they get pulled in several
times over by different headers.



-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
