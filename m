Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35381 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759259AbdCVRQV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Mar 2017 13:16:21 -0400
MIME-Version: 1.0
In-Reply-To: <20170321190339.GE17872@fieldses.org>
References: <20170302160211.30451-1-kolga@netapp.com> <20170302160211.30451-3-kolga@netapp.com>
 <20170302160714.GA4760@lst.de> <0ADCDD29-61BA-46CA-902C-06A6F7D06450@netapp.com>
 <20170315180913.GB18135@fieldses.org> <20170321155000.GB15402@fieldses.org>
 <56CDE406-AE24-40E4-852C-1C47C5CCD37E@netapp.com> <20170321190339.GE17872@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 22 Mar 2017 13:16:19 -0400
Message-ID: <CAN-5tyEWoaakR5+RppcSLD5AvRyizURBbPv+NNAtoFDM25dKmg@mail.gmail.com>
Subject: Re: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Christoph Hellwig <hch@lst.de>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 21, 2017 at 3:03 PM, J. Bruce Fields <bfields@fieldses.org> wro=
te:
> On Tue, Mar 21, 2017 at 12:03:08PM -0400, Olga Kornievskaia wrote:
>> Thank you for the update. I guess I don=E2=80=99t see how the proposed N=
FS
>> implementation is complicated and ugly (but I=E2=80=99m biased). I=E2=80=
=99ll try to
>> give you some performance number. My 1 data point (1gb) inter copy
>> showed 30% improvement (how can that be ignored).
>
> That would be useful, thanks--if it comes with some details about the
> setup.

What I have available to me are two laptops that I run my VMs on. It
is not a setup that is representative of a real setup. I think this
setup can only provide percent improvement numbers.

Andy was suggesting that perhaps the performance lab at Redhat would
be able to do some testing of the patches for some real world
performance?

> I'm not so curious about percent improvement, as how to predict the
> performance on a given network.
>
> If server-to-server copy looks like it's normally able to use close to
> the available bandwidth between the two servers, and if a traditional
> read-write-copy loop is similarly able to use the available bandwidth,
> then I can figure out whether server-to-server copy will help on my
> setup.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
