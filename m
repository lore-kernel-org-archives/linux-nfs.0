Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33092 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544AbbDXLZD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:25:03 -0400
MIME-Version: 1.0
In-Reply-To: <20150420185720.GA27895@fieldses.org>
References: <cover.1427471526.git.agruenba@redhat.com>
	<063d443cc0ddc5db271cdaa6649443eb699736d0.1427471526.git.agruenba@redhat.com>
	<20150420185720.GA27895@fieldses.org>
Date: Fri, 24 Apr 2015 13:25:02 +0200
Message-ID: <CAHpGcMKF=RQ=zxqfr4hW=ky0tt4jV3qMEuNgc1W-oE3SNj1cEw@mail.gmail.com>
Subject: Re: [RFC 02/39] uapi: Remove kernel internal declaration
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-04-20 20:57 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Fri, Mar 27, 2015 at 05:50:00PM +0100, Andreas Gruenbacher wrote:
>> The enum nfs4_acl_whotype is only used in nfs4d's internal nfs4 acl
>> representation. No longer expose it to user space.
>
> I'll go ahead and apply that now.

There's other very low-hanging fruit for nfsd as well:

nfsd: Checking for acl support does not require fetching any acls
https://git.kernel.org/cgit/linux/kernel/git/agruen/linux-richacl.git/commit/?h=richacl-2015-04-24&id=b3a09e6f1071ea01de64aa3071cb533e79fb4b18

nfsd: Remove dead declarations
https://git.kernel.org/cgit/linux/kernel/git/agruen/linux-richacl.git/commit/?h=richacl-2015-04-24&id=e6e2fa620584c6e2375572191fff7337a902805a

And for nfs:

nfs: Remove unused xdr page offsets in getacl/setacl arguments
https://git.kernel.org/cgit/linux/kernel/git/agruen/linux-richacl.git/commit/?h=richacl-2015-04-24&id=082664972e957e6585c059865a397185ba7d5c88

Thanks,
Andreas
