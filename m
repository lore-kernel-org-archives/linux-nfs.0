From: Martin Wilck <martin.wilck@fujitsu-siemens.com>
Subject: Re: nfsroot & RPC_AUTH_NULL
Date: Mon, 19 Jul 2004 15:08:41 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40FBC7D9.9070906@fujitsu-siemens.com>
References: <34126.68.42.103.198.1073925525.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BmWsn-0004XJ-Ty
	for nfs@lists.sourceforge.net; Mon, 19 Jul 2004 05:04:37 -0700
Received: from plam.fujitsu-siemens.com ([217.115.66.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BmWsn-00023g-6H
	for nfs@lists.sourceforge.net; Mon, 19 Jul 2004 05:04:37 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <34126.68.42.103.198.1073925525.squirrel@webmail.uio.no>
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

Hello Trond, hello list,

I have to reiterate my request from January regarding the RPC_AUTH_NULL 
used in mnt_create(). Trond had a patch long ago that simply used 
RPC_AUTH_UNIX instead RPC_AUTH_NULL. 
(http://marc.theaimsgroup.com/?l=linux-nfs&m=105390025122641&w=2)
We verified that this fixes Linux NFS boot with certain NFSv3 servers.

Trond wrote on 2004/01/12:

>>Can the above mentioned patch have any adverse effects?
>>If no, is there any reason why it did not become part of either the
>>mainline kernel or the patch collection at
>>http://www.fys.uio.no/%7Etrondmy/src/ ?
> 
> No reason at all. Please just blame my failing memory for not having
> done so already.
> 
> I'll try to get this done over the next couple of days together with the
> other patches that are missing: There are the locking patches - anything
> else?.

The issue seems to have been lost again though, at least for 2.4. The 
patch is neither in 2.4.26 nor in Trond's patch packet for 2.4.26. In 
the 2.6 series it was apparently merged with 2.6.5. It would be nice to 
have it in 2.4 as well, though.

Can I do anything to help this issue get fixed in 2.4.x?

Thanks,
Martin

-- 
Martin Wilck                Phone: +49 5251 8 15113
Fujitsu Siemens Computers   Fax:   +49 5251 8 20409
Heinz-Nixdorf-Ring 1        mailto:Martin.Wilck@Fujitsu-Siemens.com
D-33106 Paderborn           http://www.fujitsu-siemens.com/primergy



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
