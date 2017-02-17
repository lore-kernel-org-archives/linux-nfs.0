Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27850 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932303AbdBQUK4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 15:10:56 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFS: Always wait for I/O completion before unlock
Date: Fri, 17 Feb 2017 15:10:53 -0500
Message-ID: <7C3CA5DE-D19A-498C-950F-1413C30DE338@redhat.com>
In-Reply-To: <1487359849.23558.1.camel@primarydata.com>
References: <cover.1487356965.git.bcodding@redhat.com>
 <d81a853ea1ee4ba1294c85bbed7aa7298852b180.1487356965.git.bcodding@redhat.com>
 <1487358041.11929.7.camel@primarydata.com>
 <46DADA84-BE1F-43A6-8196-2A097435829A@redhat.com>
 <1487359849.23558.1.camel@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17 Feb 2017, at 14:30, Trond Myklebust wrote:
> On Fri, 2017-02-17 at 14:15 -0500, Benjamin Coddington wrote:
>> To avoid an unnecessary recovery situation where the server asks us to
>> resend I/O due to an invalid stateid.
>
> I agree we shouldn't recover in this situation. It would be better to
> jettison the failed write, and invalidate the page. Can we make use of
> nfs_wb_page_cancel() together with generic_error_remove_page()?

I'll take a look..

Ben
