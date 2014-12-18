Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48944 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638AbaLRQa0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 11:30:26 -0500
Date: Thu, 18 Dec 2014 11:30:26 -0500
To: Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
Message-ID: <20141218163026.GE18179@fieldses.org>
References: <pan.2014.12.16.22.19.18@googlemail.com>
 <20141217212159.GA11517@fieldses.org>
 <5492C710.20104@googlemail.com>
 <20141218144856.GA18179@fieldses.org>
 <pan.2014.12.18.15.35.45@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <pan.2014.12.18.15.35.45@googlemail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 18, 2014 at 03:35:45PM +0000, Holger Hoffstätte wrote:
> On Thu, 18 Dec 2014 09:48:56 -0500, J. Bruce Fields wrote:
> 
> > On a quick skim, the server's READDIR responses look correct.  The entry
> > btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch
> > is returned in frame 53 (with complete reassembled reply displayed by
> > wireshark in frame 63).
> > 
> > You could double-check for me--just run "wireshark nfs-server.pcap",
> > look for packets labeled "Reply ... READDIR", and expand out the READDIR
> > op and directory listing.  I don't see anything obviously wrong.
> 
> That's what I can see in Wireshark as well (#53 as part of the "20 
> reassembled segments"). As I said in my followup I don't think there is 
> anything wrong with that particular file since removing others "fixed" 
> the problem. That's why I suspected NIC/TCP buggery, and since my kernels 
> usually have a bunch of patches (the ones in that repo) I wanted to try 
> vanilla 3.18.0/1 as well as -3.14.27 first.
> 
> >> Meanwhile I'll try older/plain (unpatched) kernels. So far reverting
> >> the client to vanilla 3.18.1 or 3.14.27 has not helped..
> > 
> > I'm a little unclear: when you said "All this is on freshly baked
> > 3.18.1", are you describing the client, or the server, or both?
> 
> That was on both. As I wrote in the followups I've now also tried to
> first downgrade the clients (didn't help) and then finally found that
> 3.14.27 (both with and without my patches) on the server repeatably 
> works, regardless of client. Right now I have 3.18.1 as clients and 
> 3.14.27 on the server, and that works fine.

The way that the server encodes readdir replies changed in 3.16, so I'd
guess 3.15 will also work for you and 3.16 won't.

--b.

(PS You or your mail client seem to be trimming my address from to: and
cc: lines, I'd rather you didn't.)
