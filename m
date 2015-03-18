Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:48666 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932214AbbCRBlv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Mar 2015 21:41:51 -0400
References: <009501d060e6$b54c3780$1fe4a680$@soft-forge.com> <5508AC34.3030508@RedHat.com>
In-Reply-To: <5508AC34.3030508@RedHat.com>
Mime-Version: 1.0 (iPhone Mail 8J2)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <64DCD95C-CD5C-4A16-B6EC-49661576C466@mindspring.com>
Cc: Rupert Dance <rsdance@soft-forge.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Frank Filz <ffilzlnx@mindspring.com>
Subject: Re: Connectathon Issues
Date: Tue, 17 Mar 2015 18:26:14 -0700
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a patched cthon04 out there. I think from Jeff Layton. 

Frank

Sent from my iPhone

On Mar 17, 2015, at 3:35 PM, Steve Dickson <SteveD@redhat.com> wrote:

> On 03/17/2015 03:15 PM, Rupert Dance wrote:
>> Nroff
>> 
>> ./stat: no data in nroff.time
> I believe this has to do with the format of time 'time' command.
> stat.c expects a particular date format that changes whether 
> /usr/bin/time is used or the shell version of data. 
> 
> try adding TIME=/usr/bin/time to the top of general/runtests.wrk
> 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
