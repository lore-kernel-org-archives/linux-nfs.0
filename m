Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:43934 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753738AbdKFPh0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Nov 2017 10:37:26 -0500
Received: by mail-wm0-f66.google.com with SMTP id r68so9745732wmr.0
        for <linux-nfs@vger.kernel.org>; Mon, 06 Nov 2017 07:37:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171106151944.GC599@fieldses.org>
References: <20171027144743.15444.3407.stgit@klimt.1015granger.net>
 <CANjDDBi15wrUqnnpgBabwQLg1iz92PJkbt6vN9OBFK9E2Ng5SQ@mail.gmail.com>
 <28EB7B95-5EF6-41D0-8910-6BC7784CE28E@oracle.com> <20171106151944.GC599@fieldses.org>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Mon, 6 Nov 2017 21:06:44 +0530
Message-ID: <CANjDDBjMN5FphTg+--amuoT-9ARHY4XL2s11P=tnGn9HKszctQ@mail.gmail.com>
Subject: Re: [PATCH] svcrdma: Enqueue after setting XPT_CLOSE in completion handlers
To: Bruce Fields <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Bruce

On Mon, Nov 6, 2017 at 8:49 PM, Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Nov 03, 2017 at 05:19:30PM -0400, Chuck Lever wrote:
>> Hi Bruce-
>>
>> > On Oct 28, 2017, at 3:43 AM, Devesh Sharma <devesh.sharma@broadcom.com> wrote:
>> >
>> > looks good
>> >
>> > Reveiwed-By: Devesh Sharma <devesh.sharma@broadcom.com>
>> >
>> > On Fri, Oct 27, 2017 at 8:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> >> I noticed the server was sometimes not closing the connection after
>> >> a flushed Send. For example, if the client responds with an RNR NAK
>> >> to a Reply from the server, that client might be deadlocked, and
>> >> thus wouldn't send any more traffic. Thus the server wouldn't have
>> >> any opportunity to notice the XPT_CLOSE bit has been set.
>> >>
>> >> Enqueue the transport so that svcxprt notices the bit even if there
>> >> is no more transport activity after a flushed completion, QP access
>> >> error, or device removal event.
>> >>
>> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> >> ---
>> >> net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 ++++++++---
>> >> 1 file changed, 8 insertions(+), 3 deletions(-)
>> >>
>> >> Hi Bruce-
>> >>
>> >> Please consider this patch for v4.15. Thanks!
>>
>> I notice nfsd-next does not have this patch. Is there anything
>> else I need to do? Should I resend with Devesh's Reviewed-by
>> tag?
>
> Thanks for the reminder; applied for 4.15 with Devesh's Reviewed-by.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
