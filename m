Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928AbbCSPFa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2015 11:05:30 -0400
Message-ID: <550AE575.4000104@RedHat.com>
Date: Thu, 19 Mar 2015 11:04:21 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Frank Filz <ffilzlnx@mindspring.com>
CC: Rupert Dance <rsdance@soft-forge.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Connectathon Issues
References: <009501d060e6$b54c3780$1fe4a680$@soft-forge.com> <5508AC34.3030508@RedHat.com> <64DCD95C-CD5C-4A16-B6EC-49661576C466@mindspring.com>
In-Reply-To: <64DCD95C-CD5C-4A16-B6EC-49661576C466@mindspring.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



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
Taking a closer look there is code that is commented out that 
will solve this problem.

# if the default time command doesn't return the right format,
# you may have to use the following lines
#case `uname` in
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

