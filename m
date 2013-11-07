Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f41.google.com ([209.85.160.41]:36815 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab3KGUB7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 15:01:59 -0500
Received: by mail-pb0-f41.google.com with SMTP id wy17so1092105pbc.14
        for <linux-nfs@vger.kernel.org>; Thu, 07 Nov 2013 12:01:58 -0800 (PST)
Message-ID: <527BF1B5.4070508@primarydata.com>
Date: Thu, 07 Nov 2013 12:01:57 -0800
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: remove_stid can be incorporated into nfs4_put_delegation
References: <525CE711.1040107@primarydata.com> <1381820280-14120-1-git-send-email-bhalevy@primarydata.com> <20131104224758.GB8828@fieldses.org> <52786E74.8030505@primarydata.com> <20131107170204.GA10530@infradead.org>
In-Reply-To: <20131107170204.GA10530@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-11-07 09:02, Christoph Hellwig wrote:
> On Mon, Nov 04, 2013 at 08:05:08PM -0800, Benny Halevy wrote:
>> On 2013-11-04 14:47, J. Bruce Fields wrote:
>>> On Tue, Oct 15, 2013 at 09:58:00AM +0300, Benny Halevy wrote:
>>>> All calls to nfs4_put_delegation are preceded with remove_stid.
>>>
>>> Whoops, no, we missed the nfs4_put_delegation call in
>>> fs/nfsd/nfs4callback.c.
>>>
>>> Noticed because some pynfs tests triggered idr warnings about freeing
>>> the same id twice.
>>>
>>> I guess I'll revert.
>>
>> OK.
> 
> Not sure which patch in your submitted series it was, but with the
> whole series xfstests on NFS 4.1 crashed and burned early on.  I'd
> recommend you run xfstests to test any future changes to the state
> handling code in nfsd.
> 

Thanks. Will do.
