Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atl4mhob04.myregisteredsite.com ([209.17.115.42]:58823 "EHLO
	atl4mhob04.myregisteredsite.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752526AbbCSQ5J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2015 12:57:09 -0400
Received: from mailpod.hostingplatform.com ([10.30.71.205])
	by atl4mhob04.myregisteredsite.com (8.14.4/8.14.4) with ESMTP id t2JGv6vh012838
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 12:57:06 -0400
From: "Rupert Dance" <rsdance@soft-forge.com>
To: "'Steve Dickson'" <SteveD@redhat.com>,
        "'Frank Filz'" <ffilzlnx@mindspring.com>
Cc: <linux-nfs@vger.kernel.org>
References: <009501d060e6$b54c3780$1fe4a680$@soft-forge.com> <5508AC34.3030508@RedHat.com> <64DCD95C-CD5C-4A16-B6EC-49661576C466@mindspring.com> <550AE575.4000104@RedHat.com>
In-Reply-To: <550AE575.4000104@RedHat.com>
Subject: RE: Connectathon Issues
Date: Thu, 19 Mar 2015 12:57:01 -0400
Message-ID: <003701d06265$b85ce8e0$2916baa0$@soft-forge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve,

We tried uncommenting the code but we are still seeing failures. We are
running Connectathon on a variety of systems pairs testing both Mellanox and
Intel Hardware. Most of the combinations pass the Connectathon Basic,
Locking and Special tests but fail the General tests with the error message
"Nroff ./stat: no data in nroff.time"  

There are several other combinations that cause other errors:

1. The test hangs and no error is reported.  In these cases the client
system MUST be restarted before it becomes usable again. The server system
is restarted to get back to a known good state and clear the exports before
restarting testing

2. Connectathon Basic test hangs with the client system displaying: ./test5:
read and write

Thanks

Rupert

-----Original Message-----
From: Steve Dickson [mailto:SteveD@redhat.com] 
Sent: Thursday, March 19, 2015 11:04 AM
To: Frank Filz
Cc: Rupert Dance; linux-nfs@vger.kernel.org
Subject: Re: Connectathon Issues



On 03/17/2015 09:26 PM, Frank Filz wrote:
> There is a patched cthon04 out there. I think from Jeff Layton. 
> 
> Frank
> 
> Sent from my iPhone
> 
> On Mar 17, 2015, at 3:35 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> On 03/17/2015 03:15 PM, Rupert Dance wrote:
>>> Nroff
>>>
>>> ./stat: no data in nroff.time
>> I believe this has to do with the format of time 'time' command.
>> stat.c expects a particular date format that changes whether 
>> /usr/bin/time is used or the shell version of data.
>>
>> try adding TIME=/usr/bin/time to the top of general/runtests.wrk
Taking a closer look there is code that is commented out that will solve
this problem.

# if the default time command doesn't return the right format, # you may
have to use the following lines #case `uname` in
#[lL]inux*)
#   TIME=/usr/bin/time
#   ;;
#*)
#   TIME=/bin/time
#   ;;
#esac
#if [ ! -f $TIME ]
#then
#   TIME=/usr/bin/time
#   if [ ! -f $TIME ]
#   then
#       echo "Where is the time command?"
#       exit 1
#   fi
#fi

Maybe its time to uncomment it... 

steved.



