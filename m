Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:45239 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207Ab2F2Oxf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jun 2012 10:53:35 -0400
Date: Fri, 29 Jun 2012 22:53:32 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Mark Salter <msalter@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-next <linux-next@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs root problem in linux-next
Message-ID: <20120629145332.GA11745@localhost>
References: <1340656006.20557.30.camel@deneb.redhat.com>
 <1340666049.4362.9.camel@lade.trondhjem.org>
 <1340680664.20557.38.camel@deneb.redhat.com>
 <1340978148.2498.6.camel@lade.trondhjem.org>
 <1340981329.2514.23.camel@deneb.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1340981329.2514.23.camel@deneb.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 29, 2012 at 10:48:48AM -0400, Mark Salter wrote:
> On Fri, 2012-06-29 at 13:55 +0000, Myklebust, Trond wrote:
> > Hi Mark and Fengguang,
> > 
> > I believe that I've found the bug that was being triggered in the
> > above
> > patch. It was a mistake in the earlier patch "SUNRPC: Don't decode
> > beyond the end of the RPC reply message", which was failing to
> > correctly
> > initialise the xdr->nwords field.
> > 
> > I've now fixed it and updated the linux-next branch.
> 
> Yes, I can confirm that today's linux-next is booting correctly
> for me on an nfsroot.
> 
> Thanks!
 
I can confirm it, too. Thanks!
