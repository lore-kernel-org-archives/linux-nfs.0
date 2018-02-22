Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:46308 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933427AbeBVRmN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Feb 2018 12:42:13 -0500
Received: by mail-lf0-f66.google.com with SMTP id r80so8551619lfe.13
        for <linux-nfs@vger.kernel.org>; Thu, 22 Feb 2018 09:42:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180222003434.GD6535@fieldses.org>
References: <20180207213055.18211-1-kdsouza@redhat.com> <20180221225548.GC6535@fieldses.org>
 <20180222003434.GD6535@fieldses.org>
From: Kenneth Dsouza <kdsouza@redhat.com>
Date: Thu, 22 Feb 2018 23:12:11 +0530
Message-ID: <CAA_-hQJ7hVya1pPC6s5j+K5sn9AEN0KGJBbrr2WaOCc_scu6jw@mail.gmail.com>
Subject: Re: [PATCH] Add support for -R option in nfs4_getfacl so we can list
 the ACLs of all files and directories recursively.
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the commit.
I will try to work on (-L and -P) options.
Using getopt sounds good :)

On Thu, Feb 22, 2018 at 6:04 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Feb 21, 2018 at 05:55:48PM -0500, J. Bruce Fields wrote:
>> People have been request recursive operation and I keep not getting
>> around to it, thanks for doing this.
>>
>> How are you testing this?
>
> Also, on top of this patch (which I've committed, thanks) it might also
> be nice to:
>
>         - add -L and -P options to choose whether you want to follow
>           symlinks, as "getfacl" does.  I think this is just a matter of
>           passing the right flags to nftw.
>         - switch to using getopt instead of parsing the flags by hand
>           (looks like nfs4_setfacl already does this).
>
> --b.
