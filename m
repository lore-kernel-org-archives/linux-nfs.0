Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:47824 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbbBKXLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 18:11:39 -0500
From: Nix <nix@esperi.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: bfields@fieldses.org (J. Bruce Fields),
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix> <87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150211140714.4da42a5b@notabene.brown>
Date: Wed, 11 Feb 2015 23:11:33 +0000
In-Reply-To: <20150211140714.4da42a5b@notabene.brown> (NeilBrown's message of
	"Wed, 11 Feb 2015 14:07:14 +1100")
Message-ID: <87pp9gujq2.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11 Feb 2015, NeilBrown spake thusly:
> I wonder if something is going wrong in nfs_prime_dcache().  The code looks
> right, but it is a little complex...
>
> You could rule that out by disabling READDIRPLUS by using the nordirplus
> mount option.  If that makes the proble go away, it would be very
> interesting...
>
> A more intrusive debugging approach would be to get d_drop() to scream if the
> dentry being dropped had DCACHE_MOUNTED set.
>
> Are you able to try either of those?

I'll test both (the former first). The problem's still happening several
times a day, so I should be able to get back to you fairly fast...

-- 
NULL && (void)
