Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:53640 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752022AbeDRHF4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2018 03:05:56 -0400
Date: Wed, 18 Apr 2018 00:05:52 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180418070551.GA8764@infradead.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <CAN-5tyGDJUV6wVWoLoEy8V=RM+cF+y_JT-UkrG+7rcHv1VzgmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyGDJUV6wVWoLoEy8V=RM+cF+y_JT-UkrG+7rcHv1VzgmQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 14, 2018 at 08:32:48AM -0400, Olga Kornievskaia wrote:
> On Sat, Apr 14, 2018 at 3:22 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > What is the use case for adding all these crazy complications?
> 
> We have already provided evidence for improved performance of
> asynchronous copy vs synchronous copy. This is also foundation for the
> "inter" server-to-server copy which is coming later as it was decided
> to add the support in parts.

Well, show your evidence in the introduction of the series then.  And
synchronous copy is not the target - clone is.
