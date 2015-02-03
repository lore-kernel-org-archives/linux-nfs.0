Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:35659 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbbBCAUz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 19:20:55 -0500
From: Nix <nix@esperi.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruno =?utf-8?Q?Pr=C3=A9mont?= <bonbons@linux-vserver.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [Patch] sunrpc: NULL utsname dereference on NFS umount during namespace cleanup
References: <20150125220604.090121ae@neptune.home>
	<CAHQdGtSNmera4P6ocFGbLhjmESB8oV9zKE_x_zTm=5qUg7e7Ug@mail.gmail.com>
	<1422661761.21259.5.camel@primarydata.com>
	<87zj8z7p99.fsf@spindle.srvr.nix> <87d25s2ota.fsf@spindle.srvr.nix>
	<CAHQdGtT=_ZeXvG2BQjy7wYeM+APnnPiF-vTTJOu3aCyVBWG=xw@mail.gmail.com>
Date: Tue, 03 Feb 2015 00:20:49 +0000
In-Reply-To: <CAHQdGtT=_ZeXvG2BQjy7wYeM+APnnPiF-vTTJOu3aCyVBWG=xw@mail.gmail.com>
	(Trond Myklebust's message of "Mon, 2 Feb 2015 17:54:50 -0500")
Message-ID: <87mw4vu9pa.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2 Feb 2015, Trond Myklebust verbalised:
> Hmm... I'm at a loss to see how rpcb_create can ever call
> rpc_new_client() with a null value for the nodename with that patch
> applied. Are you 100% sure that the above Oops came from a patched
> kernel? That IP address of "rpc_new_client+0x13b/0x1f2" looks
> identical to the one in your original posting.

I've been swapping kernels a lot of late due to bisection -- it is
perfectly possible that I somehow ended up running an unpatched one :/

I'll do a build from scratch with the patch and reboot into it. My
apologies if this was a false positive (which it looks quite like it
might have been: your evidence is pretty persuasive!)

-- 
NULL && (void)
