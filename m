From: Charles-Edouard Ruault <ce@idtect.com>
Subject: Re: Re: Linux 2.4.25, nfs client hangs when talking to a	MacOS
 nfs server.
Date: Wed, 17 Mar 2004 20:28:52 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4058A6F4.6070408@idtect.com>
References: <117F2C39-7800-11D8-93C6-000A95CFFC9C@idtect.com>	 <1079542707.3047.12.camel@lade.trondhjem.org>	 <4825B7F5-783A-11D8-97E9-000A95CFFC9C@idtect.com>	 <1079546462.3769.249.camel@d158140025182.Cadence.COM> <1079547364.3047.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: csc@cadence.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3gj2-0004de-1Z
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 11:29:12 -0800
Received: from charlus.dyndns.org ([81.57.109.127])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1B3gj0-0002fq-LV
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 11:29:10 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1079547364.3047.27.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>P=E5 on , 17/03/2004 klokka 13:01, skreiv Chris Croswhite:
> =20
>
>>I have seen similar issues, but with slowlaris NFS server to linux.=20
>>Never was able to resolve the issue and so moved to linux NFS server. =20
>>
>>I am willing to spend sometime on this issue if Trond can give me some
>>assistance?  I can detail the issue if you have you are available.
>>   =20
>>
>
>It's very simple: if you using UDP as the transport mechanism, then
>packets can (and *will*) be lost.
> =20
>
yep, that's why i tried switching to TCP ... but with no better result.

>This is particularly true if you are working across a net which mixes
>network speeds, since the switches have to queue data when going from
>the fast to the slower net: once this queue has built up to the point
>where the switch runs out of memory, it will start dropping incoming
>packets.
>
>IOW: this is not an NFS client bug, it is a network design bug.
>
> =20
>
We'll see if this disappears after we've finished migrating the network=20
to 1Gbps

>In these environments you *must* use TCP, since that has congestion
>control capabilities baked into the protocol...
>
>For more detailed info on how to deal with this sort of problem, I
>suggest the NFS FAQ and HOWTO: see http://nfs.sourceforge.net/
>
> =20
>
I'll definitely have a look and try again with TCP just in case i can=20
capture a different error log.
Thanks again for the info.

>Cheers,
>  Trond
> =20
>



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
