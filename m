Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43971 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbEARiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 13:38:00 -0400
Date: Fri, 1 May 2015 10:37:59 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH, RFC] backchannel overflows
Message-ID: <20150501173759.GA23778@infradead.org>
References: <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
 <20150429173454.GA23284@fieldses.org>
 <20150430062558.GA25660@infradead.org>
 <2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com>
 <20150430143731.GA22038@infradead.org>
 <CAHQdGtRgEVXidNNYtYf4c3uS0vc6fbm-SZ5AxrY=awXYynmACw@mail.gmail.com>
 <20CCFEFF-8D28-431C-A1E2-5E42FB42D8FB@oracle.com>
 <E905ADC8-AB2B-45A7-87FD-0ADF660EA811@oracle.com>
 <20150501172345.GB29624@infradead.org>
 <CAHQdGtTAiwQ4rRpLCtS+V04n6hSg3R4Q3V_QFn+V2OR7bK+41w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTAiwQ4rRpLCtS+V04n6hSg3R4Q3V_QFn+V2OR7bK+41w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2015 at 01:28:12PM -0400, Trond Myklebust wrote:
> The concern is not so much static vs dynamic. The concern is limiting
> incoming RPC calls to the number allowed by the NFSv4.1 session. Right
> now, the static allocation enforces the limit of 1 slot that the
> client offers to the server (albeit with the race) and so I want any
> replacement to meet the same requirement.

Either variant will allow accepting more than one backchannel
request at the RPC layer, that's the whole point.  With the simple
patch I posted it will accept a 2nd one, with dynamic allocation
the number would be potentially unbound.

But given that the NFS client already enforces the slot limit
properly in validate_seqid, and even returns the proper nfs error
for this case I don't really see what enforcing it at a lower level
we we can't even report proper errors buys us.
