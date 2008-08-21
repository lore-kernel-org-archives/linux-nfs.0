From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: [PATCH 3/8] SUNRPC: Set V6ONLY socket option for RPC listener
 sockets
Date: Thu, 21 Aug 2008 17:32:02 +0200
Message-ID: <48AD8A72.2040200@bull.net>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net> <20080813223953.13068.97829.stgit@manray.1015granger.net> <20080814200554.GI23859@fieldses.org> <74E488BD-DB15-41CD-AD30-A8A5213BC140@oracle.com> <20080814203833.GK23859@fieldses.org> <A8AF0C9D-B606-4EA4-9EE0-5367C515BE84@oracle.com> <20080820193126.GB21226@fieldses.org> <48AD5B85.4020807@bull.net> <20080821144117.GB22587@fieldses.org>
Reply-To: aime.le-rouzic@bull.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org,
	Frank S Filz <ffilz@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:49393 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbYHUPcJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2008 11:32:09 -0400
In-Reply-To: <20080821144117.GB22587@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields a =C3=A9crit :

>>J. Bruce Fields a =C3=A9crit :
>>   =20
>>
>>>>>so suppose I'm a server
>>>>>administrator, and want my nfs server to listen for ipv6 connectio=
ns.
>>>>>Will there be some switch I'll need to flip?
>>>>>         =20
>>>>>
>
> =20
>
>>>On Thu, Aug 14, 2008 at 04:45:31PM -0400, Chuck Lever wrote:
>>>     =20
>>>
>>>>I don't know how that UI will be designed.  So far, I've focused on=
ly=20
>>>>on the pieces needed for client side IPv6 support.  I figured the=20
>>>>Bull team had something figured out for the server, and didn't thin=
k=20
>>>>any more about it.
>>>>       =20
>>>>
>>>I've forgotten who was working on that; Aurelien Charbon?
>>>     =20
>>>
>
>On Thu, Aug 21, 2008 at 02:11:49PM +0200, Le Rouzic wrote:
> =20
>
>>Sorry for not answering before, I am back from vacation.  Aurelien is
>>no longer directly working on that even he can answer any  questions.
>>It is me now who tess NFSV4 IPV6 with the patches Aurelien delivered
>>to Bruce a few months ago.  But since Chuck has delivered several new
>>patches which affect the NFS server side about the way nfsd can liste=
n
>>for ipv6 connections.
>>   =20
>>
>
>I merged the last patch I can remember from Aurelien (f15364bd "IPv6
>support for NFS server export caches").  Are there some others floatin=
g
>around that I should look at?
>
> =20
>
>> To have NFSV4 IPV6 working with those changes, what it would be nice
>> to have a complete list on what are the changes.  Is there now a
>> complete release for which we can test those latest  changes? If not
>> which one will be?  Are there any other changes still planned?
>>   =20
>>
>
>I was hoping you or Chuck would know; I don't know of anyone else
>working on nfs over ipv6.
> =20
>
   Hi,
About changes I was talking about changes introduced for IPv6 RPC=20
services via rpcbind
at least thoses published on the 19th on this mailing list can be=20
considered like the last
ones.

Cheers

>--b.
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" i=
n
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> =20
>


--=20
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic=20
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
=46ax     : 33 (4) 76.29.75.18
-----------------------------------------------------------------=20

