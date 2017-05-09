Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20853 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbdEINnw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 09:43:52 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 29/32] RFC: sunrpc: remove pc_count
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1494332183.4209.5.camel@primarydata.com>
Date: Tue, 9 May 2017 09:43:37 -0400
Cc: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <B1D4B91F-244F-4293-9188-280872712442@oracle.com>
References: <20170509092010.30752-1-hch@lst.de> <20170509092010.30752-30-hch@lst.de> <1494332183.4209.5.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 9, 2017, at 8:16 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
>> On Tue, 2017-05-09 at 11:20 +0200, Christoph Hellwig wrote:
>> pc_count is the only writeable memeber of struct svc_procinfo, which
>> is
>> a good candidate to be const-ified as it contains function pointers.
>> 
>> This patch just removes it and returns zero in the /proc file as the
>> count of calls per procedure doesn't seem all that useful.Â Â But it's
>> just a dumb hack and we might need a proper fix instead.
>> 
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> ---
>> 
> 
> For now, why not just move it to a separate non-const structure that is
> pointed to by the const one? We shouldn't deliberately break nfsstat...

Agree on both counts.


> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> N‹§²æìr¸›yúèšØb²X¬¶Ç§vØ^–)Þº{.nÇ+‰·¥Š{±û"žØ^n‡r¡ö¦zËëh™¨è­Ú&¢ø®G«éh®(­éšŽŠÝ¢j"ú¶m§ÿïêäz¹Þ–Šàþf£¢·hšˆ§~ˆmš

