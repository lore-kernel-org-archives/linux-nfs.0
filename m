Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f53.google.com ([209.85.216.53]:46617 "EHLO
	mail-vn0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516AbbFVLlM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2015 07:41:12 -0400
Received: by vnbf7 with SMTP id f7so3115045vnb.13
        for <linux-nfs@vger.kernel.org>; Mon, 22 Jun 2015 04:41:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150622175318.6e840b23@noble>
References: <20150622175318.6e840b23@noble>
Date: Mon, 22 Jun 2015 07:41:11 -0400
Message-ID: <CAHQdGtS2P7gU+9NWjEX5ejrtntMFv+8v6WCPRf3b7XCLuVXxLQ@mail.gmail.com>
Subject: Re: [PATCH/RFC] NFSv4 - do not accept an incompatible delegation.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On Mon, Jun 22, 2015 at 3:53 AM, NeilBrown <neilb@suse.de> wrote:
>
> Hi,
>  this is my proposed solution to the problem I outlined in
>    NFSv4 state management issue - Linux disagrees with Netapp.
>  I haven't tested it yet (no direct access to the Netapp), but
>  I'll try to get some testing done.  RFC for now.
>
> NeilBrown
>
>
> When opening a file, nfs _nfs4_do_open() will return any
> incompatible delegation, meaning if the delegation held for
> that file does not give all the permissions required, it is
> returned.
> This is because various places assume that the current delegation
> provides all necessary access.
>
> However when a delegation is received, it is not validated in the
> same way so it is possible to, for example, hold a read-only
> delegation while the file is open write-only.
> When that delegation is recalled, the NFS client will try to
> reclaim the write-only open, and that will fail.
>

I'd argue that the bug here is the attempt to reclaim the write-only
open; your previous email appeared to show that the client already
held a corresponding open stateid.

Cheers
  Trond
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
