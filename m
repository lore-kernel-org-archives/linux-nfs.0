Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f174.google.com ([209.85.128.174]:45021 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347AbaFCXIA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 19:08:00 -0400
Received: by mail-ve0-f174.google.com with SMTP id jw12so7860887veb.33
        for <linux-nfs@vger.kernel.org>; Tue, 03 Jun 2014 16:07:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <538E12B9.8030007@oracle.com>
References: <538DF0F5.8090500@netapp.com>
	<CAHQdGtT8y2rcPcjOJveKvPsFm30OpOJNOXZcPHtqRGVMKqSSvA@mail.gmail.com>
	<538E0008.1010709@netapp.com>
	<CAHQdGtRTV0UvZ=X0hnyWeE4Pb2hHAOJpTRp0ZETgDkt+9_03ig@mail.gmail.com>
	<538E12B9.8030007@oracle.com>
Date: Tue, 3 Jun 2014 19:07:59 -0400
Message-ID: <CAHQdGtQdBjXCgQe62AV_Vm2uct9OtZw4t5AA3NKikA8_0rQ81A@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client RDMA changes for 3.16
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 3, 2014 at 2:23 PM, Shirley Ma <shirley.ma@oracle.com> wrote:
>
>
> On 06/03/2014 10:53 AM, Trond Myklebust wrote:
>> On Tue, Jun 3, 2014 at 1:04 PM, Anna Schumaker
>> <Anna.Schumaker@netapp.com> wrote:
>>> I pulled from Chuck's branch earlier today before sending this.  He has all the date stamps set as June 2.
>>>
>>
>> OK, this is broken and I'm not pulling. The point of asking you to
>> maintain the tree was to ensure that the patches get reviewed by you,
>> and that I have signed-off-bys etc showing that is the case.
>
> Thanks Trond for checking. Where was broken? What we can help here?

Hi Shirley,

I meant that the process was broken, since I was losing the
information about what Anna had reviewed and so the issue was how to
fix that. I've now talked to Chuck and Anna and we've set up a model
for how to work together in the future: the model I'd like to see is
for Anna to publish a branch of patches that she has reviewed, with
the signed-off-by line. That way I know that the contents are the
exact same patches that were approved on the mailing lists.

Cheers
  Trond

>>> On 06/03/2014 12:44 PM, Trond Myklebust wrote:
>>>> On Tue, Jun 3, 2014 at 11:59 AM, Anna Schumaker
>>>> <Anna.Schumaker@netapp.com> wrote:
>>>>> Hey Trond,
>>>>>
>>>>> The following changes since commit fad01e866afdbe01a1f3ec06a39c3a8b9e197014:
>>>>>
>>>>>   Linux 3.15-rc8 (2014-06-01 19:12:24 -0700)
>>>>>
>>>>
>>>> Did you rebase these? All the commits appear to be labeled with
>>>> today's date, and Chuck appears as the committer for all of them.
>>>>
>>>
>
> Shirley
>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
