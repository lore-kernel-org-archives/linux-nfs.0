From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 2/5] nfsd: Fix independence of a few nfsd related	headers
Date: Wed, 11 Nov 2009 16:57:46 +0200
Message-ID: <4AFAD0EA.2080909@panasas.com>
References: <4ADEC1EF.8040107@panasas.com> <1256112873-32495-1-git-send-email-bharrosh@panasas.com> <1256171298.6809.1.camel@heimdal.trondhjem.org> <4AE01569.9000002@panasas.com> <1256220146.6402.23.camel@heimdal.trondhjem.org> <4AE08165.2040100@panasas.com> <20091104220927.GS11637@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:39611 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755903AbZKKO5o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 09:57:44 -0500
In-Reply-To: <20091104220927.GS11637@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/05/2009 12:09 AM, J. Bruce Fields wrote:
> On Thu, Oct 22, 2009 at 05:59:33PM +0200, Boaz Harrosh wrote:
> 
> I'm assuming Trond's objection is just to the patch changelog
> (specifically, to the statement that any header "should be compilation
> independent"), not to these specific changes.
> 
> --b.

Ping

Bruce? Trond? whatsup?

Can Benny put these patches in his tree? He said he would be happy to hold
them for a while, but only if they will be eventually accepted into the
tree as a pnfs pre-requisite. Please ACK on these patches?

I have to make all these put-the-includes-back patches to just make the tree
compile.

Boaz
