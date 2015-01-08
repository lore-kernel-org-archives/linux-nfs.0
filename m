Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:23281 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753171AbbAHPaS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2015 10:30:18 -0500
Message-ID: <54AEA04F.8090300@Netapp.com>
Date: Thu, 8 Jan 2015 10:20:47 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Tom Haynes <thomas.haynes@primarydata.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 00/49] *** Add Flexfile Layout Module ***
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com> <20150108144559.GA11530@infradead.org>
In-Reply-To: <20150108144559.GA11530@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/08/2015 09:45 AM, Christoph Hellwig wrote:
> Do you also have a git tree available?  I'd like to test that the
> core pnfs changes don't cause regressions for the block layout driver.
> 
> Talking about testing, where can I get the flexfiles server to test this
> layout?

How much testing has been done on these patches?  Make sure you're at least running xfstests (and probably nfsometer)!

Anna

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

