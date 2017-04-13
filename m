Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:34609 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756181AbdDMUOR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Apr 2017 16:14:17 -0400
Subject: Re: RFC: fixing kernel oops on interrupted COMMIT from
 nfs_commit_file
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trondmy@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bjschuma@netapp.com" <bjschuma@netapp.com>
References: <CAN-5tyHD9NspwAzL2YwoQGwcUk52ak0OWZ-dBfwpW6nynAf1Og@mail.gmail.com>
 <1492109480.7917.1.camel@primarydata.com>
 <CAN-5tyGOsUdWgjhNO8gvYabW-wx6ybmwUZGNLfY8rtmBiP=p_w@mail.gmail.com>
 <bed72de9-5cf8-c8a3-f59f-9bf52f3702a1@Netapp.com>
Message-ID: <9eb6ccc9-501a-5635-05f9-7bd2fd4f4563@Netapp.com>
Date: Thu, 13 Apr 2017 16:13:52 -0400
MIME-Version: 1.0
In-Reply-To: <bed72de9-5cf8-c8a3-f59f-9bf52f3702a1@Netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/13/2017 03:16 PM, Anna Schumaker wrote:
> 
> 
> On 04/13/2017 03:07 PM, Olga Kornievskaia wrote:
>> On Thu, Apr 13, 2017 at 2:51 PM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>>> On Thu, 2017-04-13 at 14:00 -0400, Olga Kornievskaia wrote:
>>>> Hi folks,
>>>>
>>>> Looking for suggestions on how to fix a kernel oops.
>>>>
>>>> It's possible that there is a ctrl-c when the COMMIT is send. In case
>>>> of the COPY, it calls
>>>> nfs_commit_file() which calls wait_on_commit() that is interrupted by
>>>> the crtl-c and frees the nfs_page request. So when asynchronous
>>>> COMMIT
>>>> rpc comes back it tried to use the nfs_page request and gets the
>>>> oops.
>>>>
>>>
>>> Is that call to nfs_free_request() in nfs_commit_file() correct?
>>
>> yes, nfs_commit_file() creates a new request via nfs_create_request()
>> and in the end if calls nfs_free_request();
>>
>>> It looks to me as if the same request will be freed in
>>> nfs_commit_release_pages().
>>
>> so nfs_commit_release_pages() thru the
>> nfs_unlock_and_release_request() is going to call
>> nfs_release_request() from req->wb_kref.. I'm not sure if this is
>> setup(?) for the copy commit path?
>>
>> Otherwise, it would have seem that we'd be doing a double free and I
>> haven't seen that in testing (not that it can't be true)...
> 
> I haven't seen any double-free messages during my testing either, so I thought it was okay.  It's possible I'm wrong, though.  I wonder if this is something that memory poisoning can help figure out?

After some experimenting, I can still use the nfs_page after nfs_commit_inode() has returned withotu any memory issues.

> 
> Anna
> 
>>
>>
>>
>>>
>>> Anna?
>>>
>>> --
>>> Trond Myklebust
>>> Linux NFS client maintainer, PrimaryData
>>> trond.myklebust@primarydata.com
