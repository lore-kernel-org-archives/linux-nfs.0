Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:49502 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756999Ab1K2WlK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 17:41:10 -0500
Message-ID: <4ED55F78.205@panasas.com>
Date: Tue, 29 Nov 2011 14:40:56 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>, <linux-nfs@vger.kernel.org>,
        <bhalevy@tonian.com>, Garth Gibson <garth@panasas.com>,
        Matt Benjamin <matt@linuxbox.com>, Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>  <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com> <1322603848.11286.7.camel@lade.trondhjem.org>
In-Reply-To: <1322603848.11286.7.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 01:57 PM, Trond Myklebust wrote:
>> Also Files when they will support segments and servers that request segments,
>> like the CEPH server, will very much enjoy the above, .i.e: Tell me the amount
>> you know you want to write.
> 
> Why would we want to add segment support to the pNFS files client???
> Segments are a nuisance that multiply the amount of unnecessary chitchat
> between the client and the MDS without providing any tangible
> benefits...
> 

Your kidding right?

One: it is mandated by the Standard, This is not an option. So a perfectly
     Standard complaint server is not Supported by Linux because we don't see
     the point.

Two: There are already file-layout servers out there (multiple) which are
     waiting for the Linux files-layout segment support, because the underline
     FS requires Segments and now they do not work with the Linux client. These
     are CEPH and GPFS and more.

The reason Netapp don't see a point is not a factor. I have not seen a netapp
server doing a top 100 HPC cluster either.

If the server hates the "unnecessary chitchat between the client and the MDS"
It can serve all-file layout and that is that. But some servers don't have
that privilege. Real big storage clusters with 1000thnds of DSs the data layout
might only be properly described by segments.

Let the fight begin. All the segmented file-layout servers out there. Now is
the time to take a stand.

Heart
