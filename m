Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:38352 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750718AbdAXTkT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 14:40:19 -0500
Received: by mail-it0-f54.google.com with SMTP id c7so97384424itd.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 11:40:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <35619FC0-AD46-4BBA-9F5B-9C89364BAF82@primarydata.com>
References: <CAN-5tyF+Uth87mnmWC2UaRU134whqNG8gEyNHBR_hOu9OYSZuw@mail.gmail.com>
 <35619FC0-AD46-4BBA-9F5B-9C89364BAF82@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 24 Jan 2017 14:40:13 -0500
Message-ID: <CAN-5tyHCUu_gpdiEcVZm-12RdgHtPtDgjbg-ScU9vZ7Tod5qAw@mail.gmail.com>
Subject: Re: handling error on RECLAIM_COMPLETE
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2017 at 2:12 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Jan 24, 2017, at 14:06, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> Hi Trond,
>>
>> Is there a reason that nfs4_proc_reclaim_complete() isn't  wrapped
>> with a do while() to handle errors?
>
> What do we not already handle correctly in nfs4_reclaim_complete_done()?

Could this be because when an error occurs rpc_done isn't called
(rpc_release is called)? What I see is that if RECLAIM_COMPLETE gets
an error (BAD_SESSION) the client just ignores it.
