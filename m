Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:37545 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966869AbcIVTGn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 15:06:43 -0400
Received: by mail-it0-f44.google.com with SMTP id 186so91559666itf.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 12:06:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2C29AA79-AC3D-403B-B112-A8C3B5DA3687@primarydata.com>
References: <CAN-5tyGvm9ZLcL2AGGzALCtJ90fEc1SHeod6V4ZpSf8WSHUJtQ@mail.gmail.com>
 <2C29AA79-AC3D-403B-B112-A8C3B5DA3687@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 22 Sep 2016 15:06:42 -0400
Message-ID: <CAN-5tyFvH3O=b+NS2SocHAOOeTmrRPj+CaJn1sUiqL_g_DrgDg@mail.gmail.com>
Subject: Re: sunrpc's tcp_max_slot_table_entries
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 22, 2016 at 12:44 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
> On Sep 22, 2016, at 12:19, Olga Kornievskaia <aglo@umich.edu> wrote:
>
> Hi folks,
>
> There used to be a configurable parameter in sunrpc called
> "tcp_max_slot_table_entries" that no longer works (meaning that rpc
> slot table is always created with 65536 slots regardless of what the
> value is set to). Is the change intentional or a bug? A look thru git
> log of xprtsock.c didn't reveal an entry stating of such change.
>
>
>
> See
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=98f98cf571b7b
>
> Cheers
>   Trond

Thanks Trond.
