Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:40530 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790AbbBJRs4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2015 12:48:56 -0500
From: Nix <nix@esperi.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: bfields@fieldses.org (J. Bruce Fields),
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix> <87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
Date: Tue, 10 Feb 2015 17:48:48 +0000
In-Reply-To: <20150205112641.60340f71@notabene.brown> (NeilBrown's message of
	"Thu, 5 Feb 2015 11:26:41 +1100")
Message-ID: <87zj8l7j3z.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5 Feb 2015, NeilBrown spake thusly:

> On Wed, 04 Feb 2015 23:28:17 +0000 Nix <nix@esperi.org.uk> wrote:
>> It doesn't. It still recurs.
>
> Is /usr/archive still exported to mutilate with crossmnt?
> If it is, can you change to not do that (it is quite possible to have
> different export options for different clients).

OK. Adjusted.

> I think that if crossmnt is enabled on the server, then explicitly
> mounting /usr/archive/series will have the same net effect as not doing so
> (though I'm not 100% certain).
>
> Also, can you try changing
>    /proc/sys/fs/nfs/nfs_mountpoint_timeout
>
> It defaults to 500 (seconds - time for light from Sun to reach Earth).
> If you make it smaller and the problem gets worse, or make it much bigger
> and the problem goes away, that would be interesting.
> If it makes no difference, that also would be interesting.

Seems to make no difference, which is distinctly surprising. If
anything, it happens more often at the default value than at either the
high or low values. It's very erratic: it happened ten times in one day,
then three days passed and it didn't happen at all... system under
very similar load the whole time.
