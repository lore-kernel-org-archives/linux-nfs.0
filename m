Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:26656 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755222Ab2IRF2S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Sep 2012 01:28:18 -0400
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only server?
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120918115450.5c65973f@notabene.brown>
Date: Tue, 18 Sep 2012 01:28:09 -0400
Cc: NFS <linux-nfs@vger.kernel.org>
Message-Id: <F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com>
References: <20120918115450.5c65973f@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

On Sep 17, 2012, at 9:54 PM, NeilBrown wrote:

> It seems that with current nfs-utils, "proto=udp" (either
> in /etc/nfsmount.conf or on the command line) restricts the mount to using
> IPv4, not IPv6.
> For IPv6 you need "udp6".
> 
> This isn't made crystal clear by the documentation.  I could fix the
> documentation, but first I wanted to check if this really is appropriate.
> Is there a good reason for this, or should we make "udp" mean "udp4 or udp6"
> and require either "udp4" or "udp6" if we want a particular IP version.
> 
> i.e. instead of treating the "proto=" value as a "netid", should we treat it
> as a "protoname" and match any "netid" in /etc/netconfig with that
> "protoname"??

This is working as designed.

The meaning of each netid is defined in RFC 5665.  "udp" means UDP over IPv4.  This matches precisely what "proto=udp" meant before TI-RPC.  These netids force a particular protocol family when the server is specified by hostname and not IP address.

What's more, we mean this to match the behavior of the Solaris mount command, where "proto=udp" also has this meaning.

Which part of the documentation do you think is unclear?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




