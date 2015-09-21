Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:34925 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756760AbbIUVUD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 17:20:03 -0400
Received: by lagj9 with SMTP id j9so77197138lag.2
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2015 14:19:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150918184014.GB21506@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-16-git-send-email-agruenba@redhat.com>
	<20150918184014.GB21506@fieldses.org>
Date: Mon, 21 Sep 2015 23:19:59 +0200
Message-ID: <CAHc6FU5mV9uVP9CjtDtKpJyTMRsn7hsArWXeKRp_xSeSPoCjnA@mail.gmail.com>
Subject: Re: [RFC v7 15/41] richacl: Automatic Inheritance
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-18 20:40 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Sep 05, 2015 at 12:27:10PM +0200, Andreas Gruenbacher wrote:
>> Automatic Inheritance (AI) allows changes to the acl of a directory to
> In the above "file" sometimes means "any object" and somethings "a
> non-directory".  I can sort it out, but more consistent terminology
> would help.

Okay, I'll fix it.

>> Linux does not have a way of creating files without setting the file
>> permission bits, so all files created inside a directory with
>> RICHACL_AUTO_INHERIT set will have the RICHACL_PROTECTED flag set.  This
>> effectively disables Automatic Inheritance.
>>
>> Protocols which support creating files without specifying permissions
>> can explicitly clear the RICHACL_PROTECTED flag after creating a file
>> and reset the file masks to "undo" applying the create mode; see
>> richacl_compute_max_masks().  They should set the RICHACL_DEFAULTED
>> flag.  This is a workaround; a mechanism that would allow a process to
>> indicate to the kernel to ignore the create mode when there are
>> inherited permissions would fix this problem.
>
> Also, as you know: current nfsd has no way to create files without
> setting permissions.  And if we were to implement that it's unclear how
> many clients would actually use it (Windows clients are rare).  And of
> course Samba doesn't have the interfaces it would need.
>
> I think we should just drop this for now.  The rest of the richacl stuff
> is still useful without it.

Samba will hack around it and adjust the ACL after the create; that's
still better than not having Automatic Inheritance. Windows uses AI
all the time so AI is more important for Samba than for NFSv4.

Thanks,
Andreas
