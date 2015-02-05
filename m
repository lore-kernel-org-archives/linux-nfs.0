Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:4891 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757900AbbBEQEs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2015 11:04:48 -0500
Message-ID: <54D3949C.4000005@Netapp.com>
Date: Thu, 5 Feb 2015 11:04:44 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/4] NFSD: nfsd4_encode_read() should encode eof and
 maxcount
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com> <1422477777-27933-2-git-send-email-Anna.Schumaker@Netapp.com> <20150205141138.GB4522@infradead.org>
In-Reply-To: <20150205141138.GB4522@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2015 09:11 AM, Christoph Hellwig wrote:
> The subject line should include readv instead of read as well, shouldn't
> it?
> 

Probably, yeah.  I'll fix that up.
