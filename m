From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: Weird exportfs behavior
Date: Tue, 19 Jan 2010 15:59:33 -0500
Message-ID: <1263934773.2399.162.camel@moss-terrapins.epoch.ncsc.mil>
References: <1263933130.2399.160.camel@moss-terrapins.epoch.ncsc.mil>
	 <20100119204828.GJ5694@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.67.2]:49594 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759Ab0ASVEU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jan 2010 16:04:20 -0500
In-Reply-To: <20100119204828.GJ5694@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-01-19 at 15:48 -0500, J. Bruce Fields wrote:
> On Tue, Jan 19, 2010 at 03:32:10PM -0500, David P. Quigley wrote:
> > Hello,
> > 	I'm working on a new export option for labeled nfs and I'm getting some
> > really weird behavior out of exportfs. I reverted my work to see if it
> > was the cause of the problem however the error still persists. For a
> > while I was getting errors about exportfs not knowing about
> > no_all_squashlabelloc=key so I tried to fix that and in the process I'd
> > had managed to get it to ignore labelloc all together. I don't think
> > that is the cause of the problems though. When I cat /var/lib/nfs/etab I
> > get a really weird line.
> > 
> > /exports	*(rw,sync,wdelay,security_label,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=0,anonuid=65534,anongid=65534,sec=unix,rw,root_squash,no_all_squash)
> > 
> > if you notice rw,root_squash, and no_all_squash are in that line twice.
> 
> That's normal; it also allows some flags to vary on a
> per-security-flavor basis, so that last bit:
> 
> 	sec=unix,rw,root_squash,no_all_squash
> 
> is just telling you what their values are for the specific sec=unix
> case.  It's redundant but harmless.
> 
> > I can't seem to figure out where the second set of those come from. I
> > believe that is causing the problem with my labelloc export because I
> > can't figure out how to get the last no_all_squash to have a comma after
> > it.
> 
> Looks like you have to modify both support/nfs/exports.c:putexportent()
> and utils/exportfs/exportfs.c:dump(), in addition to parseopts().
> (Which is really confusing.  Someone should fix that..) Maybe you're
> forgetting one of those?
> 
> --b.

I'm almost certain I am. I'll look over my patches again to take a look
at that. I also need to look over my update code for the kernel export
function because I was getting the labelloc entry in /var/lib/nfs/etab
on initial daemon start but subsequent exportfs options seem to make it
go away.

Thanks,
	Dave

