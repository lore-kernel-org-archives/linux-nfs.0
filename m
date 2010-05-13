Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:35319 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949Ab0EMNtx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 09:49:53 -0400
Message-ID: <4BEC0373.9040606@atlas.cz>
Date: Thu, 13 May 2010 15:49:39 +0200
From: Jiri Kortus <sumix@atlas.cz>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: pNFS-related questions
References: <4BEB283C.1020102@atlas.cz> <4BEBBF92.4020705@panasas.com>
In-Reply-To: <4BEBBF92.4020705@panasas.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dne 13.5.2010 11:00, Boaz Harrosh napsal(a):
> On 05/13/2010 01:14 AM, Jiri Kortus wrote:
>    
>> Hi,
>>
>> I'd like to ask two questions that are related to pNFS, I hope it's not
>> a problem that I put them in one post even though they aren't related
>> one to the other.
>>
>> 1. How to configure a pNFS+exofs setup with multiple OSD targets? I was
>> able to use a setup with one OSD target, one OSD initiator+pNFS metadata
>> server and one client with the help of pNFS mailing list and the
>> instructions from here
>> http://mailman.open-osd.org/pipermail/osd-dev/2009-July/001033.html
>> which seems to be quite clear to me. But I've been thinking about how a
>> setup with more OSDs would look like? (I mean mainly the metadata
>> server). I suppose that I would configure more OSDs in the same way as I
>> did with one. Then how about the pNFS MDS setup? I've been wondering if
>> I could do it this way:
>> - login to the targets, then mount /dev/osdX devices for example in
>> /exofs/osdX
>> - set up the /etc/exports file in this way:
>> /exofs    *(....,fsid=0,pnfs)
>> /exofs/osd1    *(....)
>> /exofs/osd2    *(....)
>> ...
>> /exofs/osdX    *(....)
>>
>>      
> No not at all! ;-)
>
> I'll be a paper about an experiment I did on Panasas labs with 8 osds and
> 8 clients 1 MDS. I'll be posting the complete scripts I used for setup and tests
>
> So it is much more simple really.
>
> - On X machines you just run ./up to load the osd-target.
>    You now have X ip addresses/names
> - On MDS/client you change your ./do-osd script to look like this (I'm attaching the complete script)
> 	login_iscsi_osd()
> 	{
> 		echo login into: $1 expect $2
> 		if $iscsiadm $ISCSI_DBG -m discovery -t sendtargets -p $1 --login; then
> 			echo $iscsiadm $ISCSI_DBG -m discovery -t sendtargets -p $1 --login returned error ($?)!
> 			sleep 3;
> 		fi
> 	
> 		sleep 1;
> 		ls $2
> 	}
> 	And then the do_start changes to:
> 	start_iscsi_intiator
>
> 	start_open_osd
>
> 	login_iscsi_osd $IP_OSD0 $DEV_OSD0
> 	login_iscsi_osd $IP_OSD1 $DEV_OSD1
> 	login_iscsi_osd $IP_OSD2 $DEV_OSD2
> 	login_iscsi_osd $IP_OSD3 $DEV_OSD3
>
> 	login_iscsi_osd $IP_OSD4 $DEV_OSD4
> 	login_iscsi_osd $IP_OSD5 $DEV_OSD5
> 	login_iscsi_osd $IP_OSD6 $DEV_OSD6
> 	login_iscsi_osd $IP_OSD7 $DEV_OSD7
>
>     So basically before hand on client and MDS you login to all osds
>
> - On MDS at one time you do a "format" (see attached script) which mkfs.exofs
>    of a file systems with all the OSDs included (Yes exofs is multy device that's
>    the all point. mirrors strips and groups are all supported)
>
>    First do a format on MDS. Then do ./do-osd stop. Then do-osd start on MDS and all
>    clients. Because format changes the osd-names and they must get updated in memory.
>
> - Then you do the export just exactly as before just one /exp/exofs and exportfs -r.
>    (Again this does not change from before)
>
> - Finally you do the do-pnfs start on clients exactlly the same as before.
>    There is a single file system. The pnfs/osd protocol takes care of all the
>    multiple devices and file layouts.
>
> So to sumerize the only thing different from before is that you need to iscsi login
> to more then one OSD. And that the mkfs.exofs command has lots of devices.
> (Or you can wait for my paper next week)
>
> Boaz
>    

Hi Boaz,

thank you for describing how it works :) It looks good and quite simple 
to grasp.
I'd like to ask you whether you would be also so kind as to write me 
some information about the IPv6 support?

Thank you very much.

Best regards,

Jiri

>> - then reload the exports by running "exportfs -r"
>> - and finally I would login to the OSDs on the client, load
>> objlayoutdriver and mount the export from MDS with the "minorversion=1"
>> option.
>> Could the content of /etc/exports file look like that? Or is it
>> fundamentally wrong? I'd be glad for any advice. I can't test it right
>> now but I have to know how to do it to describe it in my bachelor's thesis.
>>
>>
>> 2. I'd like to know how well the IPv6 support in pNFS works - what
>> works, what doesn't, if there are any problems to solve etc., just
>> anything worth to know concerning the IPv6 support.
>>
>> Thank you very much in advance.
>>
>> Best regards,
>>
>> Jiri Kortus
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>      
>    

