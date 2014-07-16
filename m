Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:38467 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaGPVko (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 17:40:44 -0400
Received: by mail-vc0-f170.google.com with SMTP id lf12so2948490vcb.15
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 14:40:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140716205846.GE2397@fieldses.org>
References: <1405202462-50244-1-git-send-email-trond.myklebust@primarydata.com>
	<20140716205846.GE2397@fieldses.org>
Date: Wed, 16 Jul 2014 14:40:43 -0700
Message-ID: <CAHQdGtS+0mvbWUJiwYE8ZgsirZ6Baw1q4hZ_TjFjJgX4-HYbmw@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: xdr_get_next_encode_buffer should be declared static
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 1:58 PM, Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Jul 12, 2014 at 06:01:02PM -0400, Trond Myklebust wrote:
>> Quell another sparse warning.
>
> I think jlayton sent you the same fix with his set of sunrpc sparse
> fixes--could you just take that instead?
>
> (Or I can take this if you still want, I don't really care.)

I wasn't planning on carrying either patch in my tree. I've offloaded
the merge job to you... :-)
IOW: feel free to take Jeff's patch if that is more convenient.

Cheers,
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
