Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:60087 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757401AbbBEMAM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 07:00:12 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id C00BA2802A8
	for <linux-nfs@vger.kernel.org>; Thu,  5 Feb 2015 13:00:10 +0100 (CET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id A944913E9C
	for <linux-nfs@vger.kernel.org>; Thu,  5 Feb 2015 13:00:09 +0100 (MET)
Date: Thu, 5 Feb 2015 13:00:08 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: dE <de.techno@gmail.com>, linux-nfs@vger.kernel.org
Message-ID: <1934902055.820990.1423137608454.JavaMail.zimbra@desy.de>
In-Reply-To: <54D34CB8.1040008@plexistor.com>
References: <54D237A5.1050302@gmail.com> <20150204170356.14e1e381@harpe.intellique.com> <54D24403.2080403@gmail.com> <54D34CB8.1040008@plexistor.com>
Subject: Re: Cant get to export this particular directory.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Boaz Harrosh" <boaz@plexistor.com>
> To: "dE" <de.techno@gmail.com>, linux-nfs@vger.kernel.org
> Sent: Thursday, February 5, 2015 11:58:00 AM
> Subject: Re: Cant get to export this particular directory.

> On 02/04/2015 06:08 PM, dE wrote:
>> On 02/04/15 21:33, Emmanuel Florac wrote:
>>> Le Wed, 04 Feb 2015 20:45:49 +0530
>>> dE <de.techno@gmail.com> écrivait:
>>>
>>>> I'm trying to export a particular directory with these parameters --
>>>>
>>>> /home/test/huge/temp_small/subdir
>>>> fc00::5000/124(ro,anonuid=1000,anongid=1000,subtree_check)
>>>>
>>>> For all subdirectories in temp_small, the client fails to mount
>>>> saying permission denied.
>>> Is temp_small a mountpoint? What are the mount options?
>>>
>> 
>> No, the previous directory is (huge)
>> 
>> /dev/sda15 on /home/test/huge type reiser4 (rw,noatime)
> 
> Sorry if this is a stupid question, but what is "reiser4" filesystem ?
> 
> Looking at the Kernel source I have, I see registered "reiserfs" filesystem.
> 
> Reason I'm asking is because it looks a little bit like when the FS does not
> support the export_operations vector. The Kernel nfsd is not very good

Then this does not explain why mounting on a local host works.

Tigran.

> in complaining about it properly
> 
> Boaz
> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
