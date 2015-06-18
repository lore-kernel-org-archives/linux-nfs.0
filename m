Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:34651 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754277AbbFRLtx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 07:49:53 -0400
Received: by ykfl8 with SMTP id l8so63808357ykf.1
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 04:49:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55827B8D.3070103@control.lth.se>
References: <55827B8D.3070103@control.lth.se>
Date: Thu, 18 Jun 2015 07:49:52 -0400
Message-ID: <CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>
Subject: Re: Mount regression between 4.0.4 client and 2.6.35 server
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anders Blomdell <anders.blomdell@control.lth.se>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2015 at 4:04 AM, Anders Blomdell
<anders.blomdell@control.lth.se> wrote:
>
> I have a problem with a 4.0.4 client refusing to mount from a 2.6.35 server
> due to NFS4ERR_INVAL returned during nfs4_discover_server_trunking. See
> https://bugzilla.redhat.com/show_bug.cgi?id=1228272.


Why should we change the clients if the server is in clear and obvious
violation of the spec?

Cheers
  Trond
