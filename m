Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42282 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758040AbdCUTDl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Mar 2017 15:03:41 -0400
Date: Tue, 21 Mar 2017 15:03:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Subject: Re: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
Message-ID: <20170321190339.GE17872@fieldses.org>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-3-kolga@netapp.com>
 <20170302160714.GA4760@lst.de>
 <0ADCDD29-61BA-46CA-902C-06A6F7D06450@netapp.com>
 <20170315180913.GB18135@fieldses.org>
 <20170321155000.GB15402@fieldses.org>
 <56CDE406-AE24-40E4-852C-1C47C5CCD37E@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <56CDE406-AE24-40E4-852C-1C47C5CCD37E@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 21, 2017 at 12:03:08PM -0400, Olga Kornievskaia wrote:
> Thank you for the update. I guess I don’t see how the proposed NFS
> implementation is complicated and ugly (but I’m biased). I’ll try to
> give you some performance number. My 1 data point (1gb) inter copy
> showed 30% improvement (how can that be ignored).

That would be useful, thanks--if it comes with some details about the
setup.

I'm not so curious about percent improvement, as how to predict the
performance on a given network.

If server-to-server copy looks like it's normally able to use close to
the available bandwidth between the two servers, and if a traditional
read-write-copy loop is similarly able to use the available bandwidth,
then I can figure out whether server-to-server copy will help on my
setup.

--b.
