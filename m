Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60208 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435AbbEKINM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2015 04:13:12 -0400
Date: Mon, 11 May 2015 10:13:09 +0200
From: David Sterba <dsterba@suse.cz>
To: NeilBrown <neilb@suse.de>
Cc: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 1/3] BTRFS: support NFSv2 export
Message-ID: <20150511081309.GI23255@suse.cz>
Reply-To: dsterba@suse.cz
References: <20150508001142.31129.7604.stgit@notabene.brown>
 <20150508001623.31129.91695.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150508001623.31129.91695.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 08, 2015 at 10:16:23AM +1000, NeilBrown wrote:
> The "fh_len" passed to ->fh_to_* is not guaranteed to be that same as
> that returned by encode_fh - it may be larger.
> 
> With NFSv2, the filehandle is fixed length, so it may appear longer
> than expected and be zero-padded.
> 
> So we must test that fh_len is at least some value, not exactly equal
> to it.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>

Acked-by: David Sterba <dsterba@suse.cz>
