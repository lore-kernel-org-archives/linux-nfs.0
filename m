Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52742 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752978AbbAEVPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 16:15:48 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t05LFlUv004046
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Jan 2015 16:15:48 -0500
Message-ID: <54AAFF02.7070301@RedHat.com>
Date: Mon, 05 Jan 2015 16:15:46 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Dave Sullivan <dsulliva@redhat.com>, linux-nfs@vger.kernel.org
CC: David Swegen <dswegen@redhat.com>
Subject: Re: possible better error handling for nfsv4 and localhost maps
References: <5481CD2F.4060607@redhat.com> <54833114.3090708@RedHat.com> <548867D6.5050703@redhat.com>
In-Reply-To: <548867D6.5050703@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/10/2014 10:33 AM, Dave Sullivan wrote:
>> Have you tried using the -o timeo=1,retry=0 mount options? They might help...
>>
> But do you really want to have all your other mounts doing this too?
> 
> I don't think so, its less resilient right.
> 
> I think the /etc/nfsmount.conf fix
> 
> [ Server "localhost" ]
>     Nfsvers=3
> 
> 
> Is 100% sufficient, but it still would be nice to have this brought 
> up to your attention easier through error handling/logging.
Understood... 

> 
> Unless in automount configuration you could force nfsv4 to 
> do -o timeo=1,retry=0 just for localhost then fallback to 
> nfsv3 with different set of options.
> 
> But I believe you would then globally being setting nfsv4 to 
> use the same -o timeo=1,retry=0 options and I don't think 
> there is fallback mechanism either.
> 
> So basically I still think to have these mounts land you still 
> want the previously document solution.
Documentation has never been a strong suite with Linux NFS...
esp with debugging... Its probably a side effect of being Opensource,
the code is the documentation! ;-) 

That said, we have to be careful not to log common errors either... 
I too have been frustrated with mounts hang with "Connection refused"
because it was using the wrong address... But its a common error so we
have to be careful about flooding syslog with common occurrences... 

I'm not sure adding more debugging code to NFS kernel or user daemons 
is the answer... What I think the answer is making the current debugging
more user friendly... 

Being able to dynamically turn on and off debugging in daemons. Added
a user friendly address (possibly a GUI) to the current tracepoints.
Tailor the existing systemtab script to make debugging situations 
like this more straightforward... 

I think efforts in these areas would pay of more than just adding 
yet more debugging code... 

steved.
