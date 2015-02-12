Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:45486 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050AbbBLBvE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 20:51:04 -0500
From: Nix <nix@esperi.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix> <87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87y4o4ujwh.fsf@spindle.srvr.nix>
	<20150212101812.10967f11@notabene.brown>
Date: Thu, 12 Feb 2015 01:50:56 +0000
In-Reply-To: <20150212101812.10967f11@notabene.brown> (NeilBrown's message of
	"Thu, 12 Feb 2015 10:18:12 +1100")
Message-ID: <87y4o3sxrz.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11 Feb 2015, NeilBrown said:

>
>> > It might be interesting to see output from
>> >
>> > 	rpc.debug -m rpc -s cache
>> > 	cat /proc/net/rpc/nfsd.export/content
>> > 	cat /proc/net/rpc/nfsd.fh/content
>> >
>> > especially after the problem manifests.
>> 
>> It's manifested right now, as a matter of fact.
>> 
>> # cat /proc/net/rpc/nfsd.export/content
>> #path domain(flags)
>> /usr/src        mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=16,uuid=333950aa:8e3f440a:bc94d0cc:4adae198,sec=1)
>> /usr/share/texlive      mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=7,uuid=5cccc224:a92440ee:b4450447:3898c2ec,sec=1)
>
> You didn't run the "rpcdebug" command first (there is no '.').
> That causes the 'content' files to contain extra information which might be
> useful.

Ah. That's because of this:

/proc/sys/sunrpc/rpc_debug: No such file or directory

Looks like I'll need to recompile with CONFIG_SUNRPC_DEBUG to do that. I
have a stable kernel upgrade coming up anyway: I'll get that done and
see if the problem recurs after the usual round-the-houses reboot...
with my luck, it'll go away :/

-- 
NULL && (void)
