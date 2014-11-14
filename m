Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35342 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161872AbaKNVgT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 16:36:19 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so4004137wid.6
        for <linux-nfs@vger.kernel.org>; Fri, 14 Nov 2014 13:36:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFYZ2s4gV-ahQ4H4kZuqjez087sSpSuUeJ4UtDdW8MNag@mail.gmail.com>
References: <CAN-5tyFYZ2s4gV-ahQ4H4kZuqjez087sSpSuUeJ4UtDdW8MNag@mail.gmail.com>
Date: Fri, 14 Nov 2014 16:36:18 -0500
Message-ID: <CAHQdGtQrs8no2Uwn9ZrTz_HXSrOwykh7H8G9q58tVSVZzXjZLQ@mail.gmail.com>
Subject: Re: calls to rpc_peeraddr2str()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Fri, Nov 14, 2014 at 11:12 AM, Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
> Should all calls to rpc_peeraddr2str() be protected with
> rcu_read_lock(). callback_proc.c makes calls to rpc_peeraddr2str()
> without acquiring such lock. Can somebody comment if this is a bug?
>

Those calls are made from inside the dprintk_rcu() macro, so they
should be safely protected by the rcu lock taken there.

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
