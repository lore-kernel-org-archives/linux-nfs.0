Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34532 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031593AbbKEQbx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 11:31:53 -0500
Received: by obbza9 with SMTP id za9so70559161obb.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2015 08:31:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <m2twp0v5hc.fsf@discipline.rit.edu>
References: <1446684228-37765-1-git-send-email-aweits@rit.edu>
	<CAHQdGtQmYV9Aq+=CivbmPTjHMZVhd8BznpMsmXXD=cZwzOO0Uw@mail.gmail.com>
	<m2twp0v5hc.fsf@discipline.rit.edu>
Date: Thu, 5 Nov 2015 11:31:53 -0500
Message-ID: <CAHQdGtQ15TFpAk+RuCCSORKe1gYNWoVD8d9a_Vxy=_44=WFo9g@mail.gmail.com>
Subject: Re: [PATCH RFC v3] nfs: nfs_do_return_delegation() needs to send FREE_STATEID
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andrew W Elble <aweits@rit.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 5, 2015 at 10:19 AM, Andrew W Elble <aweits@rit.edu> wrote:
>
>> If the server is revoking a delegation, then presumably it will also
>> set one or more of the SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED,
>> SEQ4_STATUS_ADMIN_STATE_REVOKED, SEQ4_STATUS_RECALLABLE_STATE_REVOKED,
>> which should start up a state manager thread to do the
>> test_stateid/free_stateid dance.
>>
>> So instead of adding the free stateid call above, why can't we just
>> punt the freeing of the delegation to the state manager?
>
> I inferred (perhaps incorrectly) that nfs_do_return_delegation() was a
> place delegations went to and didn't come back from.
>
> I managed to convince myself that since all callers of
> nfs_do_return_delegation() detach the delegation, the state manager
> wouldn't be able to perform that function without reattaching the
> delegation - and that doesn't look quite so safe (and/or possible)
> in all of those call paths?

Looking again more closely, can we ever have NFS_DELEGATION_REVOKED
set without first having called nfs41_check_delegation_stateid(), and
therefore presumably having freed the delegation stateid? The only
place I can see that might be broken is
ff_layout_async_handle_error_v4(), which calls
nfs_remove_bad_delegation() directly instead of using the state
manager.

There is also a question of what to do if the call to DELEGRETURN
itself returns NFS4ERR_DELEG_REVOKED, but why would a server do that?
