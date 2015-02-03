Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:34538 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966392AbbBCT5s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Feb 2015 14:57:48 -0500
From: Nix <nix@esperi.org.uk>
To: bfields@fieldses.org (J. Bruce Fields)
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
Date: Tue, 03 Feb 2015 19:57:44 +0000
In-Reply-To: <20150203195333.GQ22301@fieldses.org> (J. Bruce Fields's message
	of "Tue, 3 Feb 2015 14:53:33 -0500")
Message-ID: <87egq6lqdj.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3 Feb 2015, J. Bruce Fields spake thusly:

> On Tue, Feb 03, 2015 at 12:25:18AM +0000, Nix wrote:
>> I'm seeing this bizarre output after a long delay (memory pressure not
>> required: vapoursynth, which was running here, is using a couple of gig
>> out of 16GiB, and the machine has 12GiB in buffers/cache):
>> 
>> FileNotFoundError: [Errno 2] No such file or directory: '(unreachable)/Orphan-Black/1'
>
> Haven't really read this carefully, just noticed the ENOENT.  There was
> 49a068f82a "rpc: fix xdr_truncate_encode to handle buffer ending on page
> boundary" recently, fixing a problem introduced in 3.16 that could I
> think cause an enoent if Orphan-Black/ was a large-ish directory.

It's got three files in it. Orphan-Black/1 has fifteen. Way under, say,
a page.

The problem hasn't recurred since I mounted /usr/archive and
/usr/archive/series explicitly rather than relying on nohide, so I'd
guess the problem lies there: it is, after all, evil.

> Actually, that fix is in 3.18.3, never mind....

Guess it can't be that then :)

-- 
NULL && (void)
