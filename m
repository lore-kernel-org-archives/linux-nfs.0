Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:36756 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbbAaAo3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2015 19:44:29 -0500
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
Date: Sat, 31 Jan 2015 00:44:18 +0000
In-Reply-To: <1422661761.21259.5.camel@primarydata.com> (Trond Myklebust's
	message of "Fri, 30 Jan 2015 18:49:21 -0500")
Message-ID: <87zj8z7p99.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 30 Jan 2015, Trond Myklebust uttered the following:

> On Sun, 2015-01-25 at 16:55 -0500, Trond Myklebust wrote:
>> On Sun, Jan 25, 2015 at 4:06 PM, Bruno Prémont
>> <bonbons@linux-vserver.org> wrote:
>> > On a system running home-brown container (mntns, utsns, pidns, netns)
>> > with NFS mount-point bind-mounted into the container I hit the following
>> > trace if nfs filesystem is first umount()ed in init ns and then later
>> > umounted from container when the container exists.

I'm not using containers, but I *am* extensively bind-mounting
NFS filesystems, which probably has the same net effect.

> I was rather hoping that Bruno would fix up his patch and resend, but
> since other reports of the same bug are now surfacing... Please could
> you all check if something like the following patch fixes it.

I have to wait for another of those xprt != 0 warnings, I think. I've
had a couple of clean reboots, but I had the occasional clean reboot
even before this patch.

I'll let it run overnight and give it a reboot in the morning.

-- 
NULL && (void)
