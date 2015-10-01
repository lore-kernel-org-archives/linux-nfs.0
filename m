Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54600 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbbJARcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Oct 2015 13:32:33 -0400
Date: Thu, 1 Oct 2015 13:32:31 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Constantine Peresypkin <pconstantine@gmail.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: Is UNSTABLE ever sent in client writes?
In-Reply-To: <CAOEg9Lo4N3ceJYV0=L-Khrh-oTFZUyTTS=X5acXTg9JKfe2_YA@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1510011325260.5275@planck.local>
References: <CAOEg9Lo4N3ceJYV0=L-Khrh-oTFZUyTTS=X5acXTg9JKfe2_YA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 1 Oct 2015, Constantine Peresypkin wrote:

> Tried with various mount options (sync, async)
> Looked into source code.
> It seems like it will never be sent, client always assumes server can
> do FILE_SYNC, and server cannot respond with anything else, if
> implemented correctly.
> But what we can do if the server is inherently unable to do FILE_SYNC
> (eventual consistency, write reorder, etc.)?

Hi Constantine, my linux client does unstable writes all the time.
nfs_pgio_rpcsetup() default stable arg is NFS_UNSTABLE..

Try doing a write larger than your mount's wsize parameter.

Ben
