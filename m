From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost
 servers.
Date: Tue, 23 Nov 2004 19:46:04 -0500
Message-ID: <41A3D9CC.7040404@RedHat.com>
References: <41A39D57.8060902@RedHat.com> <20041123232636.GE19342@vestdata.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWlGL-0001G0-U4
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 16:44:01 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWlGK-00061X-Tq
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 16:44:01 -0800
To: =?ISO-8859-15?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
In-Reply-To: <20041123232636.GE19342@vestdata.no>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Ragnar Kj=F8rstad wrote:

>On Tue, Nov 23, 2004 at 03:28:07PM -0500, Steve Dickson wrote:
> =20
>
>>Here is a patch that make sure the correct hostname is used
>>in the SM_NOTIFY message what is sent from a rebooted server
>>that has multiple network interfaces.
>>
>>Using the network part of the destination address, the correct network
>>interface is found. Then a gethostbyaddr() on that interface is done,
>>which yields the correct hostname that should be sent in the notify
>>message....
>>
>>Comments?
>>   =20
>>
>
>It has been a while since I looked at this code, but:
>1. What happens when you run statd with the "-n" option?
>   Does this patch override the name the user gave?
> =20
>
hmm.... this is a problem, since the global SM_stat_chge.mon_name
that the -n sets is now ignored... I guess I was thinking it would be bet=
ter
for statd to dynamically set the name that sent the notify message.
But it would probably be a smart to maintain the same functionality.

Question: do people actually run multiple statds using the -n to define
the interface they monitor?  That's a scenario  I guess  I didn't think=20
of but
it sound a bit awkward....

>2. Does this really find the correct hostname?
>   If I'm not mistaken, the nfs client needs to get a SM_NOTIFY message
>   with the hostname that it actually mounted from, right?
> =20
>
right....

>   This may or may not match the hostname that the server find when
>   running gethostbyaddr on the interface's IP, so one can easily find
>   scenarios where this patch will cause statd to stop working.
> =20
>
I don't think this is an issue... as long as the hostname and all of its=20
aliases
resolve to the same ip address, things should work since its the ip addre=
ss
the kernel needs to find the lock that has to be reclaimed... Now the=20
problem
arises when the hostname resolves to a different ip address....=20
something this patch
is trying to address...

>   Now, there new behavious may actually be better, but I'm not sure
>   it's acceptable to change it anyway?
> =20
>
Is this truly a big thing? to explicitly define the hostname that will=20
be monitored?

>   Could an alternative be to send out SM_NOTIFY messages for multiple
>   hostnames?=20
>
I believe this is how some of the Unixs out there  do it... but that=20
always seem a bit
verbose and non-exact...

>Both the one from gethostname() and the ones found by
>   reverse lookup from the interfaces? Then I guess the meaning of the
>   "-n" option could be changed to _add_ a hostname to the list of
>   names to broadcast for?=20
> =20
>
Again I think this is a bit messy especially with hosts that have a ton=20
of interfaces and
aliases.... but anything is better than how it works today.... imho...

SteveD.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
