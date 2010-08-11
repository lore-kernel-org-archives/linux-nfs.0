Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54305 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757404Ab0HKXKs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Aug 2010 19:10:48 -0400
Date: Thu, 12 Aug 2010 09:10:41 +1000
From: Neil Brown <neilb@suse.de>
To: David Brodbeck <brodbd@u.washington.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100812091041.45362cd9@notabene>
In-Reply-To: <0969EC03-E225-4265-BADC-582F2089D13E@u.washington.edu>
References: <201008030401.33552.dreck@vmsd.ath.cx>
	<20100803164318.GB13896@merit.edu>
	<20100803192216.GC31579@fieldses.org>
	<DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
	<20100803215704.GA15494@merit.edu>
	<1280873719.14520.17.camel@heimdal.trondhjem.org>
	<20100803222337.GA9752@fieldses.org>
	<1280874675.14520.23.camel@heimdal.trondhjem.org>
	<20100803224245.GB9752@fieldses.org>
	<1280887336.24669.23.camel@heimdal.trondhjem.org>
	<0969EC03-E225-4265-BADC-582F2089D13E@u.washington.edu>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 4 Aug 2010 10:06:05 -0700
David Brodbeck <brodbd@u.washington.edu> wrote:

> I've been looking at it for a while, because the 16-group limit is a problem for us, but it's a huge ball of wax.  I understand the security benefits, but the sheer complexity of setting it up and then coming up with workarounds for ticket expiration has me a bit cowed.
> 

The 16-group limit is easily avoidable if you use Linux as your NFS server
and a given uid maps to the same gids on both client and server.
Just run mounted with "--manage-gids".
Then the gid list on an incoming request will be ignored, and replace with a
gid list obtained by doing a password/group lookup on the server.

NeilBrown
