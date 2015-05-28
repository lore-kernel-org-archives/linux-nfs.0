Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34031 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbbE1U2O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 16:28:14 -0400
MIME-Version: 1.0
In-Reply-To: <20150528195205.GC31663@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
	<4f0168389120bf67cf69ce4ac7bb8ce878aa0f5d.1429868795.git.agruenba@redhat.com>
	<20150528195205.GC31663@fieldses.org>
Date: Thu, 28 May 2015 22:28:13 +0200
Message-ID: <CAHpGcMJ1-EXQx8dxm=G4aXUkbTFDaMLFuxb33bY+tPt4_6TWBg@mail.gmail.com>
Subject: Re: [RFC v3 33/45] nfsd: Keep list of acls to dispose of in compoundargs
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-28 21:52 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Fri, Apr 24, 2015 at 01:04:30PM +0200, Andreas Gruenbacher wrote:
>> We will decode acls in requests into richacls; those need to be richacl_put()
>> at the end of the request instead of kfree()d; this allows the vfs to cache
>> them whenever possible.
>>
>> NOTE: If we allow only a single acl per request, we can get rid of the list
>> here.
>
> Technically I guess we're supposed to allow it, and maybe someday
> someone will come up with a reason....  So I'm not inclined to drop the
> list.

Okay, I'll update the comment accordingly.

Thanks,
Andreas
