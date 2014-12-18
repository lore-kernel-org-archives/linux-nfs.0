Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876AbaLROs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 09:48:58 -0500
Date: Thu, 18 Dec 2014 09:48:56 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
Message-ID: <20141218144856.GA18179@fieldses.org>
References: <pan.2014.12.16.22.19.18@googlemail.com>
 <20141217212159.GA11517@fieldses.org>
 <5492C710.20104@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5492C710.20104@googlemail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 18, 2014 at 01:22:40PM +0100, Holger Hoffstätte wrote:
> On 12/17/14 22:22, J. Bruce Fields wrote:
> > On Tue, Dec 16, 2014 at 10:19:18PM +0000, Holger Hoffstätte wrote:
> >> (..oddly broken directory over NFS..)
> > That doesn't sound familiar.  A network trace showing the READDIR would
> > be really useful.  Since this is so reproducible, I think that should be
> > possible.  So do something like:
> > 
> > 	move the problem file into 3.14/
> > 	tcpdump -s0 -wtmp.pcap -i<relevant interface>
> > 	ls the directory on the client.
> > 	kill tcpdump
> > 	send us tmp.pcap and/or take a look at it with wireshark and see
> > 	what the READDIR response looks like.
> 
> Thanks for your reply. I forgot to mention that removing other files seems to "fix" the problem, so it does not seem to be spefically the new file itself that is the cause.
> 
> I captured the "ls 3.14 | head" sequence on both the client and the server, and put the tcpudmp files here: http://hoho.duckdns.org/linux/ - let me know if that helped.

On a quick skim, the server's READDIR responses look correct.  The entry
btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch
is returned in frame 53 (with complete reassembled reply displayed by
wireshark in frame 63).

You could double-check for me--just run "wireshark nfs-server.pcap",
look for packets labeled "Reply ... READDIR", and expand out the READDIR
op and directory listing.  I don't see anything obviously wrong.

It's interesting that there's only one LOOKUP in the trace, for btrfs-20
(returning, not suprisingly, NFS4ERR_NOENT).  If the client failed to
parse that entry for some reason, then maybe in addition to getting the
filename wrong it also failed to get the attributes, triggering the
extra lookup/getattr.

> Meanwhile I'll try older/plain (unpatched) kernels. So far reverting the client to vanilla 3.18.1 or 3.14.27 has not helped..

I'm a little unclear: when you said "All this is on freshly baked
3.18.1", are you describing the client, or the server, or both?

--b.
