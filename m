Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34561 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751741AbdDNP4X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Apr 2017 11:56:23 -0400
Received: by mail-io0-f171.google.com with SMTP id a103so115338176ioj.1
        for <linux-nfs@vger.kernel.org>; Fri, 14 Apr 2017 08:56:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1492116646.11542.1.camel@primarydata.com>
References: <CAN-5tyHD9NspwAzL2YwoQGwcUk52ak0OWZ-dBfwpW6nynAf1Og@mail.gmail.com>
 <1492109480.7917.1.camel@primarydata.com> <CAN-5tyGOsUdWgjhNO8gvYabW-wx6ybmwUZGNLfY8rtmBiP=p_w@mail.gmail.com>
 <bed72de9-5cf8-c8a3-f59f-9bf52f3702a1@Netapp.com> <9eb6ccc9-501a-5635-05f9-7bd2fd4f4563@Netapp.com>
 <1492116646.11542.1.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 14 Apr 2017 11:56:21 -0400
Message-ID: <CAN-5tyFbuG44eu3WkUprs1Ym3ZA=nfSq3rQ9Zqs5sDCXvuHCpQ@mail.gmail.com>
Subject: Re: RFC: fixing kernel oops on interrupted COMMIT from nfs_commit_file
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "Anna.Schumaker@Netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bjschuma@netapp.com" <bjschuma@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 13, 2017 at 4:50 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Thu, 2017-04-13 at 16:13 -0400, Anna Schumaker wrote:
>>
>> On 04/13/2017 03:16 PM, Anna Schumaker wrote:
>> >
>> >
>> > On 04/13/2017 03:07 PM, Olga Kornievskaia wrote:
>> > > On Thu, Apr 13, 2017 at 2:51 PM, Trond Myklebust
>> > > <trondmy@primarydata.com> wrote:
>> > > > On Thu, 2017-04-13 at 14:00 -0400, Olga Kornievskaia wrote:
>> > > > > Hi folks,
>> > > > >
>> > > > > Looking for suggestions on how to fix a kernel oops.
>> > > > >
>> > > > > It's possible that there is a ctrl-c when the COMMIT is send.
>> > > > > In case
>> > > > > of the COPY, it calls
>> > > > > nfs_commit_file() which calls wait_on_commit() that is
>> > > > > interrupted by
>> > > > > the crtl-c and frees the nfs_page request. So when
>> > > > > asynchronous
>> > > > > COMMIT
>> > > > > rpc comes back it tried to use the nfs_page request and gets
>> > > > > the
>> > > > > oops.
>> > > > >
>> > > >
>> > > > Is that call to nfs_free_request() in nfs_commit_file()
>> > > > correct?
>> > >
>> > > yes, nfs_commit_file() creates a new request via
>> > > nfs_create_request()
>> > > and in the end if calls nfs_free_request();
>> > >
>> > > > It looks to me as if the same request will be freed in
>> > > > nfs_commit_release_pages().
>> > >
>> > > so nfs_commit_release_pages() thru the
>> > > nfs_unlock_and_release_request() is going to call
>> > > nfs_release_request() from req->wb_kref.. I'm not sure if this is
>> > > setup(?) for the copy commit path?
>> > >
>> > > Otherwise, it would have seem that we'd be doing a double free
>> > > and I
>> > > haven't seen that in testing (not that it can't be true)...
>> >
>> > I haven't seen any double-free messages during my testing either,
>> > so I thought it was okay.  It's possible I'm wrong, though.  I
>> > wonder if this is something that memory poisoning can help figure
>> > out?
>>
>> After some experimenting, I can still use the nfs_page after
>> nfs_commit_inode() has returned withotu any memory issues.
>>
>
> Wait...
>
> OK, so nfs_scan_commit_list() does indeed take a reference to the req-
>>wb_kref, so that balances the call to nfs_release_request() in
> nfs_commit_release_pages(), however it also means that you should not
> be calling nfs_free_request(), since doing so circumvents the
> refcounting mechanism.
>

Right now when req is created in nfs_commit_file() it starts out with wb_kref=1.
After calling, nfs_scan_commit_list() wb_kref=2
Now if in normal operations
nfs_commit_release_pages will drop that to 1
And then calling nfs_release_commit in nfs_commit_file() will finally
drop to 0 and release.
If ctrl-c happened,
then nfs_commit_file will drop the ref first but will not free it and
that will allow the commit to proceed and finish the rpc?

> Secondly, if you want to release the request and you are not sure
> whether or not it got cleared off the inode's cinfo commit list yet,
> you may also need to lock that request and call
> nfs_clear_request_commit().

Looking at what the function does, I don't see why this is needed.
"wb_page" is NULL for this type of commit and there is no pnfs in this
case.
