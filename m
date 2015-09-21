Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:32877 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755788AbbIUXUY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 19:20:24 -0400
Received: by lamp12 with SMTP id p12so76608712lam.0
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2015 16:20:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150917182219.GB13825@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-14-git-send-email-agruenba@redhat.com>
	<20150917182219.GB13825@fieldses.org>
Date: Tue, 22 Sep 2015 01:20:22 +0200
Message-ID: <CAHc6FU62o5m4J04agYjv=AWKr9fv73-G6iPkfcOR8yVTZ1nRgA@mail.gmail.com>
Subject: Re: [RFC v7 13/41] richacl: Check if an acl is equivalent to a file mode
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-17 20:22 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Sep 05, 2015 at 12:27:08PM +0200, Andreas Gruenbacher wrote:
>> ACLs are considered equivalent to file modes if they only consist of
>> owner@, group@, and everyone@ entries, the owner@ permissions do not
>> depend on whether the owner is a member in the owning group, and no
>> inheritance flags are set.  This test is used to avoid storing richacls
>> if the acl can be computed from the file permission bits.
>
> We're assuming here that it's OK for us to silently rearrange an ACL as
> long as the result is still equivalent (in the sense that the permission
> algorithm would always produce the same result).
>
> I guess that's OK by me, but it might violate user expectations in some
> simple common cases, so may be worth mentioning in documentation
> someplace if we don't already.

I've tried to be clear about that in the man pages.

Thanks,
Andreas
