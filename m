Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.stanford.edu ([171.67.219.81]:46747 "EHLO
	smtp.stanford.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752859AbbBKW6Q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 17:58:16 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: Possible NFS 4.1 client vulnerability: uninitialized/garbage kfree() in decode_cb_sequence_args()
From: David Ramos <daramos@stanford.edu>
In-Reply-To: <1423694562.7169.12.camel@primarydata.com>
Date: Wed, 11 Feb 2015 14:58:13 -0800
Cc: linux-nfs@vger.kernel.org
Message-Id: <A04649DF-1D77-4E62-86DE-C28A852A4CB9@stanford.edu>
References: <572E44F4-FA95-4D53-949F-B553974F2F2B@stanford.edu> <1423694562.7169.12.camel@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Thanks for the quick response. Your patch looks good to me.

On Feb 11, 2015, at 2:42 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> I can't see this issue as being exploitable without a fair amount of
> trouble because the above RPC request would be incoming on a TCP
> connection that was initiated by the NFSv4.1 client. If someone can do
> that level of spoofing, then they can cause all sorts of mischief for
> the client.

That’s a fair point as far as spoofing. The attack vector I had in mind was one in which a client is induced to mount an NFS volume on a malicious server (either directly, through some DNS trickery, or via automount). Even if the client shouldn’t trust the “mischievous" files being from the server, we shouldn’t let the server crash the client machine. This is clearly not as compelling as a client attacking a server, but I think it’s worth considering.

Best,
-David



