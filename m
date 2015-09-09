Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36162 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbIIRtp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2015 13:49:45 -0400
Received: by oibi136 with SMTP id i136so10186249oib.3
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2015 10:49:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQ84tUFEXaUwSngAmQst3NbjZDCSwB2jtqRqR29R4wBWg@mail.gmail.com>
References: <m2h9n3btno.fsf@discipline.rit.edu>
	<CAHQdGtQ84tUFEXaUwSngAmQst3NbjZDCSwB2jtqRqR29R4wBWg@mail.gmail.com>
Date: Wed, 9 Sep 2015 13:49:44 -0400
Message-ID: <CAHQdGtTvPPXjSm8Aq6AefMec4UEUwL6+swwav8SSFMQJMDchCA@mail.gmail.com>
Subject: Re: upgrade/downgrade race
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andrew W Elble <aweits@rit.edu>, Bruce James Fields <bfields@fieldses.org>,
        Jeffrey Layton <jeff.layton@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

+Bruce, +Jeff...

On Wed, Sep 9, 2015 at 1:12 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Sep 9, 2015 at 9:37 AM, Andrew W Elble <aweits@rit.edu> wrote:
>>
>> In attempting to troubleshoot other issues, we've run into this race
>> with 4.1.4 (both client and server) with a few cherry-picked patches
>> from upstream. This is my attempt at a redacted packet-capture.
>>
>> These all affect the same fh/stateid:
>>
>> 116 -> OPEN (will be an upgrade / for write)
>> 117 -> OPEN_DOWNGRADE (to read for the existing stateid / seqid = 0x6
>>
>> 121 -> OPEN_DOWNGRADE (completed last / seqid = 0x8)
>> 122 -> OPEN (completed first / seqid = 0x7)
>>
>> Attempts to write using that stateid fail because the stateid doesn't
>> have write access.
>>
>> Any thoughts? I can share more data from the capture if needed.
>
> Bruce & Jeff,
>
> Given that the client sent a non-zero seqid, why is the OPEN_DOWNGRADE
> being executed after the OPEN here? Surely, if that is the case, the
> server should be returning NFS4ERR_OLD_STATEID and failing the
> OPEN_DOWNGRADE operation?
>
> Cheers
>   Trond
