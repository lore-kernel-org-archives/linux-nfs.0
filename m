Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mfb01-md.ns.itscom.net ([175.177.155.109]:35750 "EHLO
        mfb01-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755875AbeEaTEt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 15:04:49 -0400
Received: from mail01-md.ns.itscom.net (mail01-md.ns.itscom.net [175.177.155.111])
        by mfb01-md.ns.itscom.net (Postfix) with ESMTP id 62891238445
        for <linux-nfs@vger.kernel.org>; Fri,  1 Jun 2018 03:57:27 +0900 (JST)
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
In-Reply-To: <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
References: <f74fae81-d1bc-1c0e-7b41-69502bd7c489@suse.de> <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com> <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de> <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com> <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de> <20180531004554.GA29116@fieldses.org> <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com> <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com> <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com> <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
Date: Fri, 01 Jun 2018 03:57:25 +0900
Message-ID: <14051.1527793045@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust:
> The model for overlayfs and all unionfs should be that security is
> enforced by the underlying filesystem _UNTIL_ the access mode is
> modified on the top level filesystem.

Agreed.
For your information, here is aufs's fundamental approach.
- don't change the task credential.
- support the writable NFS layer.
- respect the layer fs's security model.

In the case of "upper RW non-NFS + lower RO NFS layers" combination,
nfs4_acl can be a problem in the internal (copy,move)-(up,down). Yes,
this is common to overlayfs. In order to address this, aufs introduced a
rather generic solution called ICEX (Ignore Copy-Error on Xattr) and
specifying the mount option saves users from the internal error.
Still I don't think this is best and ideal solution, but the
"ignoring conditially" is a realistic solution.


(from aufs manual)
----------------------------------------
.TP
.B icexsec | icexsys | icextr | icexusr | icexoth | icex
Ignore the error on copying\-up/down XATTR.
When an internal copy\-up/down happens, aufs tries copying all XATTRs.
Here an error can happen because of the XATTR support on the dst
branch may different from the src branch. If you know how the branch
supports or unsupports XATTR, you can specify these attributes.
`icexsec' means to ignore an error on copying\-up/down XATTR categorized
as "security" (for LSM and capability). And `icexsys,' `icextr,' and
`icexusr,' are for "system" (for posix ACL), "trusted" and "user"
categories individually.
`icexoth' is for any other category. To be convenient, `icex` sets them
all.
See also linux/Documentation/filesystems/aufs/design/06xattr.txt.

(from linux/Documentation/filesystems/aufs/design/06xattr.txt in aufs source tree)
----------------------------------------
Generally the extended attributes of inode are categorized as these.
- "security" for LSM and capability.
- "system" for posix ACL, 'acl' mount option is required for the branch
  fs generally.
- "trusted" for userspace, CAP_SYS_ADMIN is required.
- "user" for userspace, 'user_xattr' mount option is required for the
  branch fs generally.

Moreover there are some other categories. Aufs handles these rather
unpopular categories as the ordinary ones, ie. there is no special
condition nor exception.

In copy-up, the support for XATTR on the dst branch may differ from the
src branch. In this case, the copy-up operation will get an error and
the original user operation which triggered the copy-up will fail. It
can happen that even all copy-up will fail.
When both of src and dst branches support XATTR and if an error occurs
during copying XATTR, then the copy-up should fail obviously. That is a
good reason and aufs should return an error to userspace. But when only
the src branch support that XATTR, aufs should not return an error.
For example, the src branch supports ACL but the dst branch doesn't
because the dst branch may natively un-support it or temporary
un-support it due to "noacl" mount option. Of course, the dst branch fs
may NOT return an error even if the XATTR is not supported. It is
totally up to the branch fs.

Anyway when the aufs internal copy-up gets an error from the dst branch
fs, then aufs tries removing the just copied entry and returns the error
to the userspace. The worst case of this situation will be all copy-up
will fail.

For the copy-up operation, there two basic approaches.
- copy the specified XATTR only (by category above), and return the
  error unconditionally if it happens.
- copy all XATTR, and ignore the error on the specified category only.

In order to support XATTR and to implement the correct behaviour, aufs
chooses the latter approach and introduces some new branch attributes,
"icexsec", "icexsys", "icextr", "icexusr", and "icexoth".
They correspond to the XATTR namespaces (see above). Additionally, to be
convenient, "icex" is also provided which means all "icex*" attributes
are set (here the word "icex" stands for "ignore copy-error on XATTR").

The meaning of these attributes is to ignore the error from setting
XATTR on that branch.
Note that aufs tries copying all XATTR unconditionally, and ignores the
error from the dst branch according to the specified attributes.

Some XATTR may have its default value. The default value may come from
the parent dir or the environment. If the default value is set at the
file creating-time, it will be overwritten by copy-up.
Some contradiction may happen I am afraid.
Do we need another attribute to stop copying XATTR? I am unsure. For
now, aufs implements the branch attributes to ignore the error.



J. R. Okajima
