Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59985 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754369Ab1HTSYB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Aug 2011 14:24:01 -0400
Subject: Re: Odd locking behavior
References: <20110819230151.GD44681@corp.sonic.net> <1313859542.7693.5.camel@lade.trondhjem.org>
From: "Haynes, Tom" <Tom.Haynes@netapp.com>
Content-Type: text/plain;
	charset="us-ascii"
In-Reply-To: <1313859542.7693.5.camel@lade.trondhjem.org>
Message-ID: <470C3D1B-DBD6-4E7B-AF0D-D0663CCA0A58@netapp.com>
Date: Sat, 20 Aug 2011 13:23:49 -0500
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Cc: "Kelsey Cummings" <kgc@corp.sonic.net>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On Aug 20, 2011, at 11:59 AM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2011-08-19 at 16:01 -0700, Kelsey Cummings wrote: 
>> I'm looking for some suggestions as to where to look next with an odd
>> nfs file locking problem with linux clients (RHEL6) and a netapp server.
>> FSC is enabled on these.
>> 
>> The rather simple example code and output says it all.  It works as
>> expected when a single process is run, when a second proccess is started
>> it works for a while and then something breaks and we start seeing it
>> take multiples of 30 seconds for the lock request to succeed.  The more
>> proccess that are run, the more likely it is to occur as well as if a
>> proccess is started on a second client.
>> 
>> When the issue is exhibiting itself, the netaps' lock status display the
>> granted and waiting locks as expected(?).
> 

Also, what version of ONTAP is the filer running?


> Does the netapp filer have multiple NICs? There is a known bug with that
> in which the filer sends GRANTED calls from the wrong IP address: see
> the description at
> http://now.netapp.com/NOW/cgi-bin/bol?Type=Detail&Display=237430
> 
> Cheers
>  Trond
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
