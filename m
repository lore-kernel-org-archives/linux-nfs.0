Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport02-1.csupomona.edu ([134.71.187.45]:9705 "EHLO
	ironport02-1.csupomona.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756128AbaLWX2q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Dec 2014 18:28:46 -0500
Date: Tue, 23 Dec 2014 15:28:44 -0800
From: Brian De Wolf <bldewolf@cpp.edu>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.14.27 client hang on specific file
Message-ID: <20141223152844.58514ad5@cpp.edu>
In-Reply-To: <20141218192421.03a66cac@cpp.edu>
References: <20141218192421.03a66cac@cpp.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Dec 2014 19:24:21 -0800
Brian De Wolf <bldewolf@cpp.edu> wrote:

> After updating our kernel from 3.4.x to 3.14.27 (along with nfs-utils
> 1.2.9), we've had a strange issue with our sec=krb5p NFSv4 mounts.
> My initial light testing went fine, but sometimes, on any given host,
> a specific file will no longer be accessible.  Any attempt to access
> it causes the process to go into uninterruptible sleep.

In case anyone else sees a similar issue, this is what I found.

3.4, 3.12 and 3.14 see stalls when accessing a Solaris 10 server.  3.4
and 3.12 recover by reconnecting after a 60 second timeout, but 3.14
hangs forever. It seems like the 3.14 timeout is broken, which is
pretty painful.  It can be recovered by resetting the TCP connection
(yay iptables), but will eventually stall again.

3.16 doesn't stall, so I assume something was fixed between 3.14 and
3.16 to handle whatever problems occur with the Solaris 10 server.
3.12 and 3.14 also don't see stalls when accessing an OmniOS server,
which makes me think the bug is on the Solaris side but triggers poor
error handling on the Linux side (that was fixed in 3.16).

So the end result is pretty obvious:  it's time to upgrade.
