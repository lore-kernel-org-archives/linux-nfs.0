Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36847 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751626AbdDMTHn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Apr 2017 15:07:43 -0400
Received: by mail-io0-f170.google.com with SMTP id l7so90115899ioe.3
        for <linux-nfs@vger.kernel.org>; Thu, 13 Apr 2017 12:07:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1492109480.7917.1.camel@primarydata.com>
References: <CAN-5tyHD9NspwAzL2YwoQGwcUk52ak0OWZ-dBfwpW6nynAf1Og@mail.gmail.com>
 <1492109480.7917.1.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 13 Apr 2017 15:07:41 -0400
Message-ID: <CAN-5tyGOsUdWgjhNO8gvYabW-wx6ybmwUZGNLfY8rtmBiP=p_w@mail.gmail.com>
Subject: Re: RFC: fixing kernel oops on interrupted COMMIT from nfs_commit_file
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bjschuma@netapp.com" <bjschuma@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 13, 2017 at 2:51 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Thu, 2017-04-13 at 14:00 -0400, Olga Kornievskaia wrote:
>> Hi folks,
>>
>> Looking for suggestions on how to fix a kernel oops.
>>
>> It's possible that there is a ctrl-c when the COMMIT is send. In case
>> of the COPY, it calls
>> nfs_commit_file() which calls wait_on_commit() that is interrupted by
>> the crtl-c and frees the nfs_page request. So when asynchronous
>> COMMIT
>> rpc comes back it tried to use the nfs_page request and gets the
>> oops.
>>
>
> Is that call to nfs_free_request() in nfs_commit_file() correct?

yes, nfs_commit_file() creates a new request via nfs_create_request()
and in the end if calls nfs_free_request();

> It looks to me as if the same request will be freed in
> nfs_commit_release_pages().

so nfs_commit_release_pages() thru the
nfs_unlock_and_release_request() is going to call
nfs_release_request() from req->wb_kref.. I'm not sure if this is
setup(?) for the copy commit path?

Otherwise, it would have seem that we'd be doing a double free and I
haven't seen that in testing (not that it can't be true)...



>
> Anna?
>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
