Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:57888 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab2HMNy5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 09:54:57 -0400
Received: by obbuo13 with SMTP id uo13so6889004obb.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 06:54:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120809181233.GB9914@fieldses.org>
References: <CAOn_VZbzhGMtYmOZJe-kGqhFLRsWpw6B3+uv+d4UAx9t1-Ew=A@mail.gmail.com>
	<20120809181233.GB9914@fieldses.org>
Date: Mon, 13 Aug 2012 19:24:56 +0530
Message-ID: <CAOn_VZaNU1_WT+XsvHabi=4fhMnyJg5eKp_p=e=1ruWfHC76DQ@mail.gmail.com>
Subject: Re: reconnect_path fails with EACCES
From: Rajesh Ghanekar <rajeshsg@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Its no_subtree_check exported.

Underneath filesystem (->permission) doesn't support capabilities and
hence EACCES is being returned. The filesystem is proprietary.
I figured it out later that they don't support capabilities.

Thanks,
Rajesh


On Thu, Aug 9, 2012 at 11:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Aug 09, 2012 at 02:55:28AM +0530, Rajesh Ghanekar wrote:
>> Hi,
>> I am facing problem with reconnect_path failing with EACCES when doing
>> lookup_one_len. I have 2 users goind to same directory, one with uid=0
>> and another with uid=xxx. Sometime for uid=0 request, nfsd is still is using
>> uid=xxx (as it was used previously), as uid=xxx doesn't have any permissions
>> on the directory.
>>
>> Should this probably do nfsd_setuser_and_check_port before
>> the below code in nfsd_set_fh_dentry()? As it carries older
>> fsuid and fsgid, can it create issues. This always happens
>> with disconnected dentries.
>>
>>         if (exp->ex_flags & NFSEXP_NOSUBTREECHECK) {
>>                 /* Elevate privileges so that the lack of 'r' or 'x'
>>                  * permission on some parent directory will
>>                  * not stop exportfs_decode_fh from being able
>>                  * to reconnect a directory into the dentry cache.
>>                  * The same problem can affect "SUBTREECHECK" exports,
>>                  * but as nfsd_acceptable depends on correct
>>                  * access control settings being in effect, we cannot
>>                  * fix that case easily.
>
> Are you exporting with subtree_check or no_subtree_check?  (What does
> "exportfs -v" say?)
>
> In the no_subtree_check case, the cap_raise_nfsd_set() is intended to
> override file permissions, so the uid and gid shouldn't matter.
>
> --b.
