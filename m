Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36046 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754217AbdDQVRd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Apr 2017 17:17:33 -0400
Received: by mail-io0-f179.google.com with SMTP id o22so46568776iod.3
        for <linux-nfs@vger.kernel.org>; Mon, 17 Apr 2017 14:17:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFfeerM6+ajswa376aotCN73kn6WQdRzb7U_E3jaz=C7Q@mail.gmail.com>
References: <CAN-5tyHD9NspwAzL2YwoQGwcUk52ak0OWZ-dBfwpW6nynAf1Og@mail.gmail.com>
 <1492109480.7917.1.camel@primarydata.com> <CAN-5tyGOsUdWgjhNO8gvYabW-wx6ybmwUZGNLfY8rtmBiP=p_w@mail.gmail.com>
 <bed72de9-5cf8-c8a3-f59f-9bf52f3702a1@Netapp.com> <9eb6ccc9-501a-5635-05f9-7bd2fd4f4563@Netapp.com>
 <1492116646.11542.1.camel@primarydata.com> <CAN-5tyFbuG44eu3WkUprs1Ym3ZA=nfSq3rQ9Zqs5sDCXvuHCpQ@mail.gmail.com>
 <1492197391.123147.1.camel@primarydata.com> <CAN-5tyFfeerM6+ajswa376aotCN73kn6WQdRzb7U_E3jaz=C7Q@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 17 Apr 2017 17:17:31 -0400
Message-ID: <CAN-5tyGneqhVMVBMge+mt+W9uwAnCadw4sxePQcamKMau6hByw@mail.gmail.com>
Subject: Re: RFC: fixing kernel oops on interrupted COMMIT from nfs_commit_file
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bjschuma@netapp.com" <bjschuma@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 14, 2017 at 5:17 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Fri, Apr 14, 2017 at 3:16 PM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
>> On Fri, 2017-04-14 at 11:56 -0400, Olga Kornievskaia wrote:
>>> On Thu, Apr 13, 2017 at 4:50 PM, Trond Myklebust
>>> <trondmy@primarydata.com> wrote:
>>> >
>>> > Secondly, if you want to release the request and you are not sure
>>> > whether or not it got cleared off the inode's cinfo commit list
>>> > yet,
>>> > you may also need to lock that request and call
>>> > nfs_clear_request_commit().
>>>
>>> Looking at what the function does, I don't see why this is needed.
>>> "wb_page" is NULL for this type of commit and there is no pnfs in
>>> this
>>> case.
>>
>> Something needs to ensure that the request is not sitting on a commit
>> list. That can happen if the commit succeeded, but returned a different
>> verifier, or it can happen if nfs_scan_commit() exits early.
>
> First point I'd like you to consider is that your last statement as a
> separate problem that needs to be solved with a different patch.
>
> Secondly, I don't understand how to determine "if nfs_commit_file()
> isn't sure whether or not request got cleared off the inode's cinfo
> commit list". There are two cases you pointed to 1) verifier mismatch
> and 2) nfs_scan_commit didn't even get to the request (caz INT_MAX
> commits were queued before that)?
>
> For the verifier mismatch: "NFS_CONTEXT_RESEND_WRITES" is set. So
> nfs_commit_file() can check for that. But I guess I'm not sure what is
> suppose to be done? Resend the commit or resend the copy?
>
> I don't really understand how to handle #2. nfs_commit_inode() return
> from doing INT_MAX commits but not doing the commit that it was
> suppose to do nfs_commit_file() asked and I'm at a loss how to
> determine that. Shouldn't there have been a loop somewhere that
> handles *all* commit requests and not just INT_MAX requests. Is this
> problem not a problem from the nfs_commit_file() but rather a generic
> problem?

Taking a different approach to fixing it by getting rid of
nfs_commit_file() and for the synchronous COPY appending COMMIT to the
compound. For the asynchronous COPY, I propose to just add a function
nfs4_proc_copy() that uses existing callback functions and just sends
the commit without messing with the commit path.
