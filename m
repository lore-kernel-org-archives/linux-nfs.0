From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost
 servers.
Date: Wed, 24 Nov 2004 17:08:11 -0500
Message-ID: <41A5064B.1030009@RedHat.com>
References: <41A39D57.8060902@RedHat.com> <20041123232636.GE19342@vestdata.no> <41A3D9CC.7040404@RedHat.com> <20041124020017.GH19342@vestdata.no> <41A477C8.4060405@RedHat.com> <20041124173525.GI19342@vestdata.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX5Go-0004FV-Qy
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 14:05:50 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CX5Gn-00007I-SG
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 14:05:50 -0800
To: =?ISO-8859-15?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
In-Reply-To: <20041124173525.GI19342@vestdata.no>
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

>On Wed, Nov 24, 2004 at 07:00:08AM -0500, Steve Dickson wrote:
> =20
>
>>>If that's the case, are we allowed to just send the IP instead of the
>>>name?
>>>
>>>
>>>     =20
>>>
>>No, since the spec says a the id_mon needs to be character string....
>>   =20
>>
>
>"10.0.0.1" is a character string as much as any - unless the
>specification says something more about this?
> =20
>
Well here is what the spec says wrt to mon_names:
"For maximum portability and interworking, it is recommended that=20
applications
and users define host names containing only the characters of the Portabl=
e
Filename Characters defined in ISO/IEC 9945-1:1990."

So doing some like would probably cause interopability issues with other
OSes....

>In short, this is exactly like what your patch does except that:
>- if there are multiple matching interfaces (e.g. aliases) we
>  send messages for all
> =20
>
Yes see your point, but is aliasing all that common in non-HA environment=
s?
The relatively simple  patch I'm proposing is a small step in the right=20
direction
which would make statd work correctly on multihome servers.
Should we strive to make statd more HA friendly, YES!  but I would
suggest one step at time.... Meaning we should propose this match to Neil
for inclusion in upstream and then build on it... imho...

SteveD.





-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
