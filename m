From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: address for lockd recovery
Date: Wed, 26 Jan 2005 07:58:38 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501260756450.15036@harp.ngdc.noaa.gov>
References: <20050125091649.70886.qmail@web51605.mail.yahoo.com>
 <1106720796.10014.10.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: mehta kiran <kiranmehta1981@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ctod5-0001Rr-Vu
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 06:58:47 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Ctod4-0006Wp-N6
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 06:58:48 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1106720796.10014.10.camel@lade.trondhjem.org>
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

On Tue, 25 Jan 2005, Trond Myklebust wrote:

> ty den 25.01.2005 Klokka 01:16 (-0800) skreiv mehta kiran:
>> Hi ,
>>      When i was checking lockd recovery ,
>>      i noted that clients after getting
>>      notification messages , use mon_id
>>      as destination address and not notication
>>      messages's source address as destination
>>      address.(as just a reply)
>>
>>      Is there any issue in using notifcation
>>      messages's source address as destination
>>      address to reclaim lock. ?
>
> If you have a multi-homed server, it does not follow that the source
> address used by rpc.statd hosts the same NFS server as the mon_name
> address.
>
> Cheers,
>  Trond
> --
> Trond Myklebust <trond.myklebust@fys.uio.no>

we are still experiencing lockd recovery failure on our multi-homed
client/servers - even with no firewall in place.  this thread makes me wonder,
is anything special required to make nfs work on a multi-homed setup?

cheers.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
