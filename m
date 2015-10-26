Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37948 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbbJZEdG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Oct 2015 00:33:06 -0400
Received: by wicll6 with SMTP id ll6so96971308wic.1
        for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2015 21:33:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151023182506.GB15564@fieldses.org>
References: <CAPrqf91BcyKjsHMK+fYm6cbxEkeU__2NYF=XZhL+TAmZ-LnzMw@mail.gmail.com>
	<20151023182506.GB15564@fieldses.org>
Date: Mon, 26 Oct 2015 10:03:05 +0530
Message-ID: <CAPrqf92Vs8F2JaAv5SDf74=iPNE09v3kExoOXea-YCGaa78xvA@mail.gmail.com>
Subject: Re: Max connurent connections limit on nfsvs server.
From: Pankaj Singh <psingh.ait@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

HI,

So this means that nfs by itself does not have a limit but it depends
on hardware, underlying filesystem and number of sockets supported by
system. Or Is it correct to say, with increase in connections (TCP)
first limit that would hit will be because of underlying filesystem's
resource consumption and it response time( time to process an RPC).

Thanks,
~Pankaj Singh

On Fri, Oct 23, 2015 at 11:55 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Oct 23, 2015 at 12:07:40PM +0530, Pankaj Singh wrote:
>> I am new to nfs.
>> What would be the max connurent connections an nfsv3 server can support?
>> Even if we are an high end hardware and fastest(have high throughput)
>> underlining file system.
>
> I don't think we can give a single number, you may hit different limits
> depending on your hardware and workload.
>
> Note that there are max_connections tunables for both nfsd and nlm
> (/porc/fs/nfsd/max_connections and
> /sys/module/lockd/parameters/nlm_max_connections) which you may need to
> adjust (but of course that doesn't solve all problems, it just controls
> some code that causes the server to drop connections past those limits.)
>
> --b.



-- 
Regards,
Pankaj SIngh
Phone No: 8826266889
