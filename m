Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eriks.xs4all.nl ([83.163.214.71]:36882 "EHLO eriks.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622Ab3ABTVl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2013 14:21:41 -0500
Message-ID: <50E488C1.6040901@slagter.name>
Date: Wed, 02 Jan 2013 20:21:37 +0100
From: Erik Slagter <erik@slagter.name>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: NFS client large rsize/wsize (tcp?) problems
References: <50E0393E.7040204@slagter.name>  <20130102182147.GA25450@fieldses.org> <50E47E83.1030208@slagter.name> <4FA345DA4F4AE44899BD2B03EEEC2FA91198300A@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91198300A@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02-01-13 19:47, Myklebust, Trond wrote:

> You probably have a NIC that doesn't support scatter-gather.

I am not 100% sure, but as it's a satellite set-top-box, with very basic
ethernet connectivity, I'd say you're right on the spot.

Is there a way to workaround that?

>> As a temporary workaround (for "dumb users" that don't know what a mount
>> option is, yes it's awful!) I'd like to modify the kernel of the clients
>> to negotiate a smaller buffer size, 32k would probably suffice. I've had
>> a few shots but have not been successful yet, can you give me a pointer
>> please?

> man nfsmount.conf

Thanks for the hint, I didn't know that! Unfortunately I can't use it,
because the mount command on the stb is a "busybox" version, so it's
very basic, and doesn't check this file (checked it using strace...)
