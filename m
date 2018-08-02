Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:37493 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726938AbeHBSen (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2018 14:34:43 -0400
Received: by mail-vk0-f45.google.com with SMTP id v72-v6so1366676vkd.4
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2018 09:42:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyERJVoiUR3ub8yjMor3YYN5ksdd93dpKoW=4OkGw6OPpg@mail.gmail.com>
References: <CAN-5tyERJVoiUR3ub8yjMor3YYN5ksdd93dpKoW=4OkGw6OPpg@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 2 Aug 2018 12:42:46 -0400
Message-ID: <CAN-5tyGeq11izA3J6mfiCnEzg1NE_9z13unx6PDy8SNK_ahASg@mail.gmail.com>
Subject: Re: noresvport and port re-use
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 2, 2018 at 11:14 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi folks,
>
> There is no documentation of this behavior but when "noresvport" is
> specified, the client will not try to re-use the port upon connection
> re-establishement. Is this an oversight or a desired behavior (ie.,
> client doesn't need to be conservative and re-use ports)?
>
> Thank you.

I'm going to speculate on the reason myself and would like to hear
some folks thoughts.

When we specify "noresvport" we use port=0 value that tells the kernel
- use any port. When connection is re-established port=0 so NFS has no
control over which port the kernel will choose.

When client re-establishes the connection with a different port, that
has an effect on the server's replay cache. Any thoughts on that?

Should the client remember which non-privileged port it used and then
the next time request a specific port? Is that possible?
