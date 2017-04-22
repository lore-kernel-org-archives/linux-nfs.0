Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:37125 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425660AbdDVQ02 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Apr 2017 12:26:28 -0400
Received: by mail-it0-f45.google.com with SMTP id x188so12802792itb.0
        for <linux-nfs@vger.kernel.org>; Sat, 22 Apr 2017 09:26:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFcE9kgiV0atOQyDV5eqKupLfoG9ACYba=bsXmYzmXyLQ@mail.gmail.com>
References: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
 <AE6F91D9-2D4E-4AA0-A1F3-EB511E53F990@primarydata.com> <CAN-5tyF3HrY9+xWO7HDnN_dv13vS9nqcp0vZpA29T=i3cJMSZg@mail.gmail.com>
 <AE31C3DC-40B8-4BBE-A5A1-A62CB656268A@primarydata.com> <CAN-5tyHgJ9K7=RChVt=sLHQbjTCRj8MhEmMipreMKWzef4Wscw@mail.gmail.com>
 <B8C98E5E-F9F5-4468-8E52-A3A4A550C1E3@primarydata.com> <CAN-5tyGC1MAq54yqQJffrNZoiaUppojmfgsqfQYrNwzhyFhoHg@mail.gmail.com>
 <F5E207D8-B71F-45BB-8114-63FF0F43136B@primarydata.com> <CAN-5tyFKk4VEdEb+P7qxGYwc6nnFvjyzCX304Jb4MAGzaJWKXA@mail.gmail.com>
 <9343A1DB-5895-41F4-8A37-504AA710D696@primarydata.com> <CAN-5tyEcv_BF60jJtAFRv3q3u3Yrqzvdhe=XWkQ2z3zKHc5C7A@mail.gmail.com>
 <CAN-5tyEoMw79hMsihpuKG=auLzir82DPqUj0fA8EycnUfPSmnw@mail.gmail.com>
 <C81A4BCC-76A8-4732-AAC1-93EF379B3302@primarydata.com> <CAN-5tyFcE9kgiV0atOQyDV5eqKupLfoG9ACYba=bsXmYzmXyLQ@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Sat, 22 Apr 2017 12:26:26 -0400
Message-ID: <CAN-5tyFnJH6Y=+brO4x5sTvsXWStH+1k-diR9OLTgXfJZXz6Xw@mail.gmail.com>
Subject: Re: reuse of slot and seq# when RPC was interrupted
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I'm still having issues with interrupted slots.

1. Client sent out an operation (X with cacheme=3Dtrue). It's waiting on
the reply by got a ctrl-c.
2. Client sends out the operation which happens to be CLOSE. It uses
the same slot and sequence id as operation X.
3. Server replies back to CLOSE with ERR_DELAY
4. Server replies to operation X
5. Client does the delay and resends the CLOSE using the same slot and
sequence id as before.
6. Server reply with X (out of the replay cache).
7. Client decoding returns back EREMOTEIO and error handling doesn't
do anything about it.

Now the problem is open state is left on the server.

If the server were to not send an ERR_DELAY first but just reply with
X then the code handles that and retries (commit a865880e20).
