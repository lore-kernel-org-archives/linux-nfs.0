Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:53921 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475AbbBDX2W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 18:28:22 -0500
From: Nix <nix@esperi.org.uk>
To: bfields@fieldses.org (J. Bruce Fields)
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
Date: Wed, 04 Feb 2015 23:28:17 +0000
In-Reply-To: <87egq6lqdj.fsf@spindle.srvr.nix> (nix@esperi.org.uk's message of
	"Tue, 03 Feb 2015 19:57:44 +0000")
Message-ID: <87r3u58df2.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3 Feb 2015, nix@esperi.org.uk outgrape:

> On 3 Feb 2015, J. Bruce Fields spake thusly:
>
>> On Tue, Feb 03, 2015 at 12:25:18AM +0000, Nix wrote:
>>> I'm seeing this bizarre output after a long delay (memory pressure not
>>> required: vapoursynth, which was running here, is using a couple of gig
>>> out of 16GiB, and the machine has 12GiB in buffers/cache):
>>> 
>>> FileNotFoundError: [Errno 2] No such file or directory: '(unreachable)/Orphan-Black/1'
>>
>> Haven't really read this carefully, just noticed the ENOENT.  There was
>> 49a068f82a "rpc: fix xdr_truncate_encode to handle buffer ending on page
>> boundary" recently, fixing a problem introduced in 3.16 that could I
>> think cause an enoent if Orphan-Black/ was a large-ish directory.
>
> It's got three files in it. Orphan-Black/1 has fifteen. Way under, say,
> a page.
>
> The problem hasn't recurred since I mounted /usr/archive and
> /usr/archive/series explicitly rather than relying on nohide, so I'd
> guess the problem lies there: it is, after all, evil.

It doesn't. It still recurs.

If I cd out of the tree entirely (say, to /tmp) then back in, the
mountpoint often reconnects for all its users: if I do things in there
(e.g. an ls) it always seems to. If I cd within the disconnected subtree
via a relative path, it doesn't.

So running this often helps:

while sleep 300; do cd /usr/archive/series/Orphan-Black/2; ls > /dev/null; cd /tmp; done

but not always -- if the thing vanishes <300s before the last problem,
we're still in for it.

-- 
NULL && (void)
