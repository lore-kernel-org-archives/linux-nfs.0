Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:56389 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbbBQRcU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2015 12:32:20 -0500
From: Nix <nix@esperi.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix> <87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
	<20150216145746.68809c0f@notabene.brown>
Date: Tue, 17 Feb 2015 17:32:12 +0000
In-Reply-To: <20150216145746.68809c0f@notabene.brown> (NeilBrown's message of
	"Mon, 16 Feb 2015 14:57:46 +1100")
Message-ID: <87sie4qw9v.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16 Feb 2015, NeilBrown verbalised:
> Make that "entry->fh->size", not "entry->fh.size" :-(

Testing underway. It'll be a few days before I can be confident that the
problem's gone (or much less time if it hasn't!).

-- 
NULL && (void)
