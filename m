Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:33475 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255Ab3HFUqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 16:46:14 -0400
From: Nix <nix@esperi.org.uk>
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        Oleg Nesterov <oleg@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "dhowells\@redhat.com" <dhowells@redhat.com>
Subject: Re: [3.10.4] NFS locking panic, plus persisting NFS shutdown panic from 3.9.*
References: <8761vlv4z9.fsf@spindle.srvr.nix>
	<20130805084436.69ee4415@corrin.poochiereds.net>
	<87siyotcri.fsf@spindle.srvr.nix>
	<20130805110427.509db424@tlielax.poochiereds.net>
	<20130805111106.73d6ab90@tlielax.poochiereds.net>
	<87zjswrvaq.fsf@spindle.srvr.nix>
	<1375719301.7337.14.camel@leira.trondhjem.org>
	<87txj4rnru.fsf@spindle.srvr.nix>
	<1375729975.7337.39.camel@leira.trondhjem.org>
Date: Tue, 06 Aug 2013 21:46:04 +0100
In-Reply-To: <1375729975.7337.39.camel@leira.trondhjem.org> (Trond Myklebust's
	message of "Mon, 5 Aug 2013 19:12:55 +0000")
Message-ID: <87pptqsg37.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5 Aug 2013, Trond Myklebust uttered the following:
> Yes. This scheme will only work if we make sure that host->h_rpcclnt is
> initialised at mount time. Here is a v2 patch that should do the right
> thing.

Confirmed, that fixes it! I'll try your shutdown crash fix next.

-- 
NULL && (void)
