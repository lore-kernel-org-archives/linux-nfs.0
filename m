From: Steve Dickson <SteveD@redhat.com>
Subject: Re: df hangs on down nfs server mounted with hard,intr,	can't
 kill
Date: Mon, 15 Mar 2004 13:15:39 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4055F2CB.4070703@RedHat.com>
References: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com>	 <20040310080910.GA21031@suse.de>	 <1078946326.1940.35.camel@nidelv.trondhjem.org>	 <20040315052106.GB17106@outblaze.com> <1079370206.2776.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Yusuf Goolamabbas <yusufg@outblaze.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B2weD-0002mL-1M
	for nfs@lists.sourceforge.net; Mon, 15 Mar 2004 10:17:09 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1B2weB-0000C9-1O
	for nfs@lists.sourceforge.net; Mon, 15 Mar 2004 10:17:07 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1079370206.2776.2.camel@lade.trondhjem.org>
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

>P=E5 m=E5 , 15/03/2004 klokka 00:21, skreiv Yusuf Goolamabbas:
> =20
>
>>Also, what's the status with the nfszerostats patch from Steve Dickson
>>of Redhat
>>
>>http://people.redhat.com/steved/NFS/nfszerostats/
>>   =20
>>
>
>Chuck is currently working on some enhanced NFS statistics patches. I
>imagine he will take steps to include Steve's patches in his work, and
>then push them to me.
> =20
>
FYI... The nfs-utils code to support nfszerostats is already
in the FC2 rawhides... I'm hopeful Neil will include this
patch in the next nfs-utils release....

SteveD.




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
