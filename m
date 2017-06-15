Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34542 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdFONHf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jun 2017 09:07:35 -0400
MIME-Version: 1.0
In-Reply-To: <20170615081502.GA10599@infradead.org>
References: <20170614170653.58083-1-kolga@netapp.com> <20170615081502.GA10599@infradead.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 15 Jun 2017 09:07:33 -0400
Message-ID: <CAN-5tyEbqtP-=XmHRSKQbRrdPJgw3tmXzW-DmXwTvMLp7xR49w@mail.gmail.com>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: Christoph Hellwig <hch@infradead.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 15, 2017 at 4:15 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Jun 14, 2017 at 01:06:53PM -0400, Olga Kornievskaia wrote:
>> This is a proposal to allow 64bit count to copy and return as
>> a result of a copy_file_range. No attempt was made to share code
>> with the 32bit function because 32bit interface should probably
>> get depreciated.
>>
>> Why use 64bit? Current uses of 32bit are by clone_file_range()
>> which could use 64bit count and NFS copy_file_range also supports
>> 64bit count value.
>
> Please provide a very good use case that actually matters to a large
> portion of the Linux users.

Reason: it will not hurt any user but it will help for
server-to-server NFS copy because for each invocation of of
copy_file_range() it requires that the client sends COPY_NOTIFY, then
COPY and then a copy triggers a establishment of clientid/session
before the reading of the source file can happen. All that could be
saved by have a 64bit value.

>> Also with this proposal off-the-bet allow the userland to copy
>> between different mount points.
>
> Totally different issue that we've discussed N times.  Trying to sneak
> it in behind peoples backs isn't going to improve the situation in any way.

I would think that sneaking would have been to remove the check and
not mention it in the commit description. I have explicitly brought
the topic up in the commit description to bring the attention to the
issue as a way to restart the conversation about the issue.

I have several times have asked for the reason to why the check can
not be removed. I'm asking again can you please explain why.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
