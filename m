Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:32832 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab1FHSKQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2011 14:10:16 -0400
Date: Wed, 8 Jun 2011 13:08:49 -0500
From: bpm@sgi.com
To: Tristan Ball <tristanb@pronto.com.au>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS Sync with External Journal
Message-ID: <20110608180849.GI26107@sgi.com>
References: <3FA034197108F04082D2AE1401CE0F3832A9B34E@VICMAILBOX.pronto.com.au>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3FA034197108F04082D2AE1401CE0F3832A9B34E@VICMAILBOX.pronto.com.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Tristan,

On Mon, Jun 06, 2011 at 01:42:39PM +0000, Tristan Ball wrote:
> I've been experimenting with using an external ext3 journal as a way
> to bring the write performance of an NFS share exported with the the
> 'sync' option closer to that of one exported with 'async'.
>
> I've mounted the ext3 filesystem with data=journal, and the journal
> itself is on SSD.  I've seen various references on the net saying that
> this should improve performance, as the nfs process can respond to
> write requests as soon as the data is in journal, rather than flushed
> all the way to the filesystem

There was some work done for xfs awhile back with a similar issue in
mind.  Once metadata are in the xfs journal the nfs server can respond
to requests without waiting for it to be flushed to its final place on
disk.  We're using the commit_metadata export_operation to do that.
But XFS won't do that for the data itself.  We rely on multiple spindles
to improve performance there.

Regards,
Ben
