From: "Sorin Faibish" <sfaibish@emc.com>
Subject: Re: [nfsv4] Linux pNFS status meeting 07/08
Date: Fri, 09 Jul 2010 07:31:15 -0400
Message-ID: <op.vfkqads4rwwil4@sfaibish1.corp.emc.com>
References: <OF60B406A7.E52268C8-ON8825775A.000C6BD9-8825775A.000C8A46@us.ibm.com> <20100708154802.GB19375@fieldses.org> <op.vfi7ssfcunckof@usensfaibisl2e.eng.emc.com> <20100708160637.GC19375@fieldses.org> <20100708174558.GE19375@fieldses.org> <op.vfj1i5vyunckof@usensfaibisl2e.eng.emc.com> <1278644957.3148.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15;
	format=flowed	delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, "Marc Eshel" <eshel@almaden.ibm.com>,
	"nfsv4 list" <nfsv4@ietf.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:20698 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654Ab0GILa7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jul 2010 07:30:59 -0400
In-Reply-To: <1278644957.3148.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 08 Jul 2010 23:09:17 -0400, Trond Myklebust =20
<trond.myklebust@fys.uio.no> wrote:

> Hi Sorin,
>
> I'm getting a 'There are no rooms available for the dates you specifi=
ed'
> reply when I try to book for the dates 10/4 to 10/8 using the link yo=
u
> provided on the web page below. Should I be using a special booking
> code?
Yes. The person I mentioned is in vacation this week and probably not a=
ll =20
the
arrangements were made. Try again on next Monday. Sorry about this I fo=
und =20
out
too late after I posted the page.

>
> Cheers
>   Trond
>
> On Thu, 2010-07-08 at 22:36 -0400, sfaibish wrote:
>> I posted a preliminary web page announcement for the Fall Bake-a-Tho=
n in
>> Boston
>> on CITI website:
>>
>>   http://www.citi.umich.edu/projects/nfsv4/citi_bakeathon/15th_nfsv4=
_bakeathon.html
>>
>>
>> On Thu, 08 Jul 2010 13:45:58 -0400, J. Bruce Fields =20
>> <bfields@fieldses.org>
>> wrote:
>>
>> > Also I'd like to hand off running and taking notes on this meeting=
 to
>> > someone else for a while.  (Benny, maybe?)  Or we can go back to =20
>> making
>> > the meeting more informal if that's preferred.
>> >
>> > --b.
>> >
>> > 1. upstream status/merge plans (trond, bfields)
>> > 	- upstream at 2.6.35-rc4.
>> > 	- server side: some bugfixes merged to callback code; allocation
>> > 	  failures changed to return DELAY.
>> > 	- discussion of error return on client callback-parsing error.
>> > 	- trond: everything from before bakeathon is in nfs-2.6.36
>> > 	  branch or upstream.  Also some file locking bugfixes
>> > 	  (bugzilla.kernel.org #14501).  Also sending release_lockowner
>> > 	  more often to keep server resources down.
>> >
>> > 2. State of pNFS tree (bhalevy)
>> > 	- working on patches from boaz and andy for release branch.
>> > 	  Anyone else have big pending patchsets?
>> > 		- Jim is getting complex-volume block patches tested,
>> > 		  will send them out soon.
>> > 		- Fred has some pending stuff ("minor cleanup")
>> > 	- next week would like to start cleaning up and squashing
>> > 	  together patches.  Also will truncate some of the history.
>> >
>> > 3. Client
>> > 	3.1. Client pNFS status
>> > 		- Andy needs to look at state reclaim stuff?
>> > 		- Andy still wondering what to do with the nfs inode
>> > 		  layout pointer.  What's the lifetime of the thing that
>> > 		  points to?
>> > 	3.2. Client state management design documentation (trond)
>> > 		- Also, on docs: Andy will check that wiki docs are
>> > 		  uptodate.  And will do some more documentation of
>> > 		  refcnts, as will Fred.
>> >
>> > 4. Server
>> > 	4.1. Todo's for minimal 4.1 server (bfields)
>> > 		- still working on callback changes.  Trond notes
>> > 		  ongoing rpc code improvements may allow us to do much
>> > 		  of this by keeping a single client and modifying its
>> > 		  transports, in which case I may be able to replace my
>> > 		  callbacks with single rpc tasks.
>> > 		- also fixing 4.0/4.1 bug that prevents exclusive locks
>> > 		  on upgraded open.
>> > 	4.2. pnfs
>> > 		- pnfs/gfs2
>> > 			- I'll ask Eric for a report on gfs2 bakeathon
>> > 			  testing.
>> > 		- exofs
>> > 			- I'll ask Brian about citi exofs setup status.
>> >
>> > 5. boston bakeathon
>> > 	- October 4-8.
>> > 	- Details are finalized, to be posted soon.
>> > 	- If your company will be bringing large equipment, let Sorin
>> > 	  know.
>> > 	- If anyone would be interested in sponsoring a reception or
>> > 	  other addition to the bakeathon, contact Sorin.  (Or if you
>> > 	  know who at your company would handle such a thing, let Sorin
>> > 	  know.)
>> >
>> > 6. new business
>> > 	- Sorin asked Trond for summary of layout-commit discussion.
>> > 	  Discussion ensued.
>> >
>> > 7. next meeting
>> > 	- next week as usual.
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" =20
>> in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >
>> >
>>
>>
>>
>
>
>
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
Unified Storage Division

        EMC=B2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
