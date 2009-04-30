From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 0/10] nfsd41 server backchannel for 2.6.31
Date: Fri, 01 May 2009 02:12:34 +0300
Message-ID: <49FA3062.9050606@panasas.com>
References: <49FA2D86.8060402@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:20833 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751943AbZD3XNY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:13:24 -0400
In-Reply-To: <49FA2D86.8060402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 01, 2009, 2:00 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> Bruce,
> 
> After squashing and merging Ricardo's latest patchset
> please review the following patchset and consider for 2.6.31.

I forgot to mention that this patchset is also available on
git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.31
which is based onto
git://git.linux-nfs.org/~bfields/linux.git for-2.6.31

Benny

> 
> Thanks,
> 
> Benny
> 
> [RFC 01/10] nfsd: cleanup nfs4.0 callback encode routines
> [RFC 02/10] nfsd: minorversion support for the back channel
> [RFC 03/10] nfsd41: sunrpc: Added rpc server-side backchannel handling
> [RFC 04/10] nfsd41: Remember the auth flavor to use for callbacks
> [RFC 05/10] nfsd41: callback infrastructure
> [RFC 06/10] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
> [RFC 07/10] nfsd41: Backchannel: Server backchannel RPC wait queue
> [RFC 08/10] nfsd41: Backchannel: Setup sequence information
> [RFC 09/10] nfsd41: cb_sequence callback
> [RFC 10/10] nfsd41: cb_recall callback
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
