Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:37280 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbaJFN5x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 09:57:53 -0400
Received: by mail-vc0-f171.google.com with SMTP id hy10so3165322vcb.16
        for <linux-nfs@vger.kernel.org>; Mon, 06 Oct 2014 06:57:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyF4oCkmHskT02GceF=CR1mYZc3uwm0tLf2fd39-XeyjRg@mail.gmail.com>
References: <CAN-5tyF4oCkmHskT02GceF=CR1mYZc3uwm0tLf2fd39-XeyjRg@mail.gmail.com>
Date: Mon, 6 Oct 2014 09:57:52 -0400
Message-ID: <CAHQdGtT39EBPx1SQTn3hFHBNuLsSoBdkSOYWHYRQ=j8vpVjB_A@mail.gmail.com>
Subject: Re: [bug] open owner value is always the same
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Mon, Oct 6, 2014 at 9:48 AM, Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
> The spec says that open owner needs to be different for different
> files yet the code returns the same value.
>
> It is not clear to me what's broken about ida_get_new() that's used
> for generation of the owner ids.
>
> Can somebody comment on this?
>

As far as I know, there is no requirement in either NFSv4 or NFSv4.1
that open owners be different for each file. In NFSv4.1 there is a
requirement that they be unique to each credential/principal, but only
if you negotiate EXCHGID4_FLAG_BIND_PRINC_STATEID.

The current choice of scheme where we share open_owners between files
was largely motivated by a desire not to overload the NFSv4.0 servers
with lots of open_owner structures. In NFSv4.0, those structures are
required to be cached by the server for a while after the file has
been closed.

Cheers
  Trond


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
