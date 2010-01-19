From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Weird exportfs behavior
Date: Tue, 19 Jan 2010 15:48:28 -0500
Message-ID: <20100119204828.GJ5694@fieldses.org>
References: <1263933130.2399.160.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40306 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753256Ab0ASUrN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jan 2010 15:47:13 -0500
In-Reply-To: <1263933130.2399.160.camel-88+Bj4OksMGWPftkNcioYDMZycKHmlmlfvIqQ387n9k@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 19, 2010 at 03:32:10PM -0500, David P. Quigley wrote:
> Hello,
> 	I'm working on a new export option for labeled nfs and I'm getting some
> really weird behavior out of exportfs. I reverted my work to see if it
> was the cause of the problem however the error still persists. For a
> while I was getting errors about exportfs not knowing about
> no_all_squashlabelloc=key so I tried to fix that and in the process I'd
> had managed to get it to ignore labelloc all together. I don't think
> that is the cause of the problems though. When I cat /var/lib/nfs/etab I
> get a really weird line.
> 
> /exports	*(rw,sync,wdelay,security_label,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=0,anonuid=65534,anongid=65534,sec=unix,rw,root_squash,no_all_squash)
> 
> if you notice rw,root_squash, and no_all_squash are in that line twice.

That's normal; it also allows some flags to vary on a
per-security-flavor basis, so that last bit:

	sec=unix,rw,root_squash,no_all_squash

is just telling you what their values are for the specific sec=unix
case.  It's redundant but harmless.

> I can't seem to figure out where the second set of those come from. I
> believe that is causing the problem with my labelloc export because I
> can't figure out how to get the last no_all_squash to have a comma after
> it.

Looks like you have to modify both support/nfs/exports.c:putexportent()
and utils/exportfs/exportfs.c:dump(), in addition to parseopts().
(Which is really confusing.  Someone should fix that..) Maybe you're
forgetting one of those?

--b.

> It seems odd to me that this is doubled and I'm guessing it might be
> a bug. I'm using the kernel and nfs-utils git hashes below.
> 
> Kernel: 22763c5cf3690a681551162c15d34d935308c8d7 (with LNFS patches)
> nfs-utils: 1a1f991870f02b303a05e1d63915226e7cfb9f53 (with LNFS patches)
> 
> Dave
> 
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
