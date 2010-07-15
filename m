From: sfaibish <sfaibish@emc.com>
Subject: Re: Linux pNFS status meeting 07/15
Date: Thu, 15 Jul 2010 16:26:02 -0400
Message-ID: <op.vfwi1ojxunckof@usensfaibisl2e.eng.emc.com>
References: <OF01D34025.9BF2DCCC-ON88257760.007510C5-88257760.007530DA@us.ibm.com> <20100714212928.GD8161@fieldses.org> <20100715172836.GC15126@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15;
	format=flowed	delsp=yes
Cc: linux-nfs@vger.kernel.org, "nfsv4 list" <nfsv4@ietf.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Marc Eshel" <eshel@almaden.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:24956 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934652Ab0GOU0R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jul 2010 16:26:17 -0400
In-Reply-To: <20100715172836.GC15126@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

=46all BAT update
Hotel reservation is posted at:
http://www.starwoodmeeting.com/Book/NFSv4Bakeathon

I will update the webpage later today at:
http://www.citi.umich.edu/projects/nfsv4/citi_bakeathon/15th_nfsv4_bake=
athon.html

/Sorin


On Thu, 15 Jul 2010 13:28:36 -0400, J. Bruce Fields <bfields@fieldses.o=
rg> =20
wrote:

>
> Notes:
>
> Bruce:
> 	- nothing to report (transitioning to new hardware, etc.)
>
> Trond:
> 	- did some fsync cleanup
> 	- bugfixes to handling of ERR_DELAY on sequence operations.
> 	- preparing for rpc changes required for migration.
> 		(some discusison here of idempotency problems on
> 		migration/reboot)
>
> Benny:
> 	- Included Trond's delay/sequence fix
> 	(missed some additional discussion)
>
> Andy:
> 	- simplification of write_pagelist/read_pagelist prototypes
> 	- making sure layouts removed on server reboot
> 	- looking at layout commit/reclaim issues in preparation for
> 	  discussion at Maastricht.
> 	- wants to rename some structures; will mail proposal to list.
>
> Jim Rees:
> 	- bugfixing complex-volume patches; not ready to submit to Benny
> 	  quite yet.
>
> Steved:
> 	- Discussion of RHEL prospects.  When will we have some pnfs
> 	  patches that are ready to review?  Concensus seems to be
> 	  2.6.36 will be too early.  Ricardo, Benny think 2.6.37
> 	  possible to finish up remaining work, squash changes into a
> 	  single cleaned-up patch series.  Trond reminds that adequate
> 	  time is required before merge window for review, especially
> 	  for large change.  Benny volunteering to do squashing.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



--=20
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

         EMC=B2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
