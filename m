Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:55985 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbbBKXIs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 18:08:48 -0500
Received: by mail-vc0-f179.google.com with SMTP id hy4so2410677vcb.10
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 15:08:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <C957EAEA-BA10-4C95-A95B-09FD0F9B12B1@stanford.edu>
References: <572E44F4-FA95-4D53-949F-B553974F2F2B@stanford.edu>
	<1423694562.7169.12.camel@primarydata.com>
	<C957EAEA-BA10-4C95-A95B-09FD0F9B12B1@stanford.edu>
Date: Wed, 11 Feb 2015 18:08:47 -0500
Message-ID: <CAHQdGtRzO5AZHTsxy7aO9Rerc4X72HK3wCV=cJgxL_YuQqNd9A@mail.gmail.com>
Subject: Re: Possible NFS 4.1 client vulnerability: uninitialized/garbage
 kfree() in decode_cb_sequence_args()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Ramos <daramos@stanford.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

On Wed, Feb 11, 2015 at 5:56 PM, David Ramos <daramos@stanford.edu> wrote:
> Hi Trond,
>
> Thanks for the quick response. Your patch looks good to me.
>
> On Feb 11, 2015, at 2:42 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>
>
> I can't see this issue as being exploitable without a fair amount of
>
> trouble because the above RPC request would be incoming on a TCP
> connection that was initiated by the NFSv4.1 client. If someone can do
> that level of spoofing, then they can cause all sorts of mischief for
> the client.
>
>
> That’s a fair point as far as spoofing. The attack vector I had in mind was
> one in which a client is induced to mount an NFS volume on a malicious
> server (either directly, through some DNS trickery, or via automount). Even
> if the client shouldn’t trust the “mischievous" files being from the server,
> we shouldn’t let the server crash the client machine. This is clearly not as
> compelling as a client attacking a server, but I think it’s worth
> considering.

If you are operating in that kind of hostile environment, then you
really should be using RPCSEC_GSS with krb5i or krb5p to protect your
payloads. I'll admit that we don't yet have proper support for
RPCSEC_GSS protection on the NFSv4.1 backchannel RPC requests, so the
particular spoofing scenario described above is still possible,
however the server and client will mutually identify each other via
RPCSEC_GSS when the TCP connection is being set up.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
