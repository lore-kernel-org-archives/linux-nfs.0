Return-Path: <nfsv4-bounces@ietf.org>
Date: Sat, 17 Jul 2010 10:58:10 -0400
To: sfaibish <sfaibish@emc.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Marc Eshel" <eshel@almaden.ibm.com>
From: "Sorin Faibish" <sfaibish@emc.com>
References: <OF01D34025.9BF2DCCC-ON88257760.007510C5-88257760.007530DA@us.ibm.com>
	<20100714212928.GD8161@fieldses.org>
	<20100715172836.GC15126@fieldses.org>
	<op.vfwi1ojxunckof@usensfaibisl2e.eng.emc.com>
Message-ID: <op.vfzs68aorwwil4@sfaibish1.corp.emc.com>
In-Reply-To: <op.vfwi1ojxunckof@usensfaibisl2e.eng.emc.com>
Cc: linux-nfs@vger.kernel.org, nfsv4 list <nfsv4@ietf.org>
Subject: Re: [nfsv4] Linux pNFS status meeting 07/15
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-15"; Format="flowed"; DelSp="yes"
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

The Fall BAT webpage was updated with all the correct hotel reservation =20
forms:
http://www.citi.umich.edu/projects/nfsv4/citi_bakeathon/15th_nfsv4_bakeatho=
n.html

Sorry for the delay.

/Sorin


On Thu, 15 Jul 2010 16:26:02 -0400, sfaibish <sfaibish@emc.com> wrote:

> Fall BAT update
> Hotel reservation is posted at:
> http://www.starwoodmeeting.com/Book/NFSv4Bakeathon
>
> I will update the webpage later today at:
> http://www.citi.umich.edu/projects/nfsv4/citi_bakeathon/15th_nfsv4_bakeat=
hon.html
>
> /Sorin
>
>
> On Thu, 15 Jul 2010 13:28:36 -0400, J. Bruce Fields =20
> <bfields@fieldses.org> wrote:
>
>>
>> Notes:
>>
>> Bruce:
>> 	- nothing to report (transitioning to new hardware, etc.)
>>
>> Trond:
>> 	- did some fsync cleanup
>> 	- bugfixes to handling of ERR_DELAY on sequence operations.
>> 	- preparing for rpc changes required for migration.
>> 		(some discusison here of idempotency problems on
>> 		migration/reboot)
>>
>> Benny:
>> 	- Included Trond's delay/sequence fix
>> 	(missed some additional discussion)
>>
>> Andy:
>> 	- simplification of write_pagelist/read_pagelist prototypes
>> 	- making sure layouts removed on server reboot
>> 	- looking at layout commit/reclaim issues in preparation for
>> 	  discussion at Maastricht.
>> 	- wants to rename some structures; will mail proposal to list.
>>
>> Jim Rees:
>> 	- bugfixing complex-volume patches; not ready to submit to Benny
>> 	  quite yet.
>>
>> Steved:
>> 	- Discussion of RHEL prospects.  When will we have some pnfs
>> 	  patches that are ready to review?  Concensus seems to be
>> 	  2.6.36 will be too early.  Ricardo, Benny think 2.6.37
>> 	  possible to finish up remaining work, squash changes into a
>> 	  single cleaned-up patch series.  Trond reminds that adequate
>> 	  time is required before merge window for review, especially
>> 	  for large change.  Benny volunteering to do squashing.
>>
>> --b.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
>
>



--=20
Best Regards
Sorin Faibish
Corporate Distinguished Engineer
Unified Storage Division

        EMC=B2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
