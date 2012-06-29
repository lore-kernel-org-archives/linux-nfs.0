Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab2F2Osv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jun 2012 10:48:51 -0400
Subject: Re: nfs root problem in linux-next
From: Mark Salter <msalter@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>,
        linux-next <linux-next@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 29 Jun 2012 10:48:48 -0400
In-Reply-To: <1340978148.2498.6.camel@lade.trondhjem.org>
References: <1340656006.20557.30.camel@deneb.redhat.com>
	 <1340666049.4362.9.camel@lade.trondhjem.org>
	 <1340680664.20557.38.camel@deneb.redhat.com>
	 <1340978148.2498.6.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
Message-ID: <1340981329.2514.23.camel@deneb.redhat.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-06-29 at 13:55 +0000, Myklebust, Trond wrote:
> Hi Mark and Fengguang,
> 
> I believe that I've found the bug that was being triggered in the
> above
> patch. It was a mistake in the earlier patch "SUNRPC: Don't decode
> beyond the end of the RPC reply message", which was failing to
> correctly
> initialise the xdr->nwords field.
> 
> I've now fixed it and updated the linux-next branch.

Yes, I can confirm that today's linux-next is booting correctly
for me on an nfsroot.

Thanks!


