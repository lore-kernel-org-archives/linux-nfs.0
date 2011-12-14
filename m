Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757119Ab1LNUb0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 15:31:26 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEKVQXW010622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 15:31:26 -0500
Message-ID: <4EE9079D.2000607@RedHat.com>
Date: Wed, 14 Dec 2011 15:31:25 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] clstated: add a daemon to track NFSv4 client names
 on stable storage (RFC)
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>	<4EE8BF63.6080906@RedHat.com>	<20111214103247.3a67515f@tlielax.poochiereds.net>	<4EE8C45B.30207@RedHat.com>	<20111214110538.2adaf048@tlielax.poochiereds.net>	<4EE8CE18.2040306@RedHat.com> <20111214113432.786ffbf7@tlielax.poochiereds.net>
In-Reply-To: <20111214113432.786ffbf7@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/14/2011 11:34 AM, Jeff Layton wrote:
> On Wed, 14 Dec 2011 11:26:00 -0500
>>>>>>> The data is stored using a sqlite database. The main reason for this is
>>>>>>> that it takes care of most of the fussy details and atomicity concerns
>>>>>>> of tracking the information on stable storage.
>>>>>> This will make nfs-utils dependent on the sqlite database... Any idea
>>>>>> what kinda of extra baggage this brings? 
>>>>>>
>>>>>
>>>>> Depends on what you mean by "baggage". What is your concern?
>>>> In Fedora doing a 'yum install sqlite' which would require
>>>> a ton of other package needing to be install... The Required
>>>> for nfs-utils is getting pretty long at this point... 
>>>>  
>>>
>>> I don't think it pulls in that much. This is pretty minimal for dependencies:
>>>
>>> $ ldd /usr/lib/libsqlite3.so.0.8.6 
>>> 	linux-gate.so.1 =>  (0x00e05000)
>>> 	libdl.so.2 => /lib/libdl.so.2 (0x001bd000)
>>> 	libpthread.so.0 => /lib/libpthread.so.0 (0x00769000)
>>> 	libc.so.6 => /lib/libc.so.6 (0x00e27000)
>>> 	/lib/ld-linux.so.2 (0x4e572000)
>>>
>>> I think the command-line tools have some dependency on ncurses and
>>> readline and such, but I don't think it's that much really...
>>>
>>> In any case, perhaps it's time to split the nfs-utils packaging for
>>> fedora into client and server pieces? Clients really only need
>>> a few of the tools, but they can't install that on fedora without
>>> getting all of the server pieces too.
>> Yeah I thinking this is quickly becoming slippery slope... In the end I'm
>> all for looking into using dbs instead of flat files but I'm just
>> worrying about the size of nfs-utils footprint... Maybe unnecessarily 
>>
>> Question, how would admin look at the list of client? Will that
>> even be needed? 
>>
> 
> Generally shouldn't be needed unless you're debugging. Today, we just
> have a bunch of directories in the v4recoverydir with md5 hash names,
> so I think moving to a DB is a step forward in this sense.
Or possible an overkill?? How large do you expect these lists
to grow? 

Also, from what the Nfsd4_server_recovery wiki says all that is
really need is "stable storage". What makes sqlite more stable
than a simple write() followed by an fsync()?
> 
> There's a sqlite3 tool that you can use to attach to the DB file(s).
> Then you can run sql commands against the tables in it. The DB layout
> at this point is very simple, so this shouldn't be too hard.
> 
> Note that I'm not dead-set on using sqlite for this if there's
> something more suitable. What I really don't want to do though is to
> reinvent the wheel. Storing info safely on stable storage is a solved
> problem, IMO...
> 
I took a look there does not appear to be any dependencies at all...
So that worry was unfounded... Whats another dependency?? ;-) Lets just
make sure using db is not overkill... then I'm good to go...

steved.

steved.
