From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: close() / nfs commit performance
Date: Sun, 06 Jul 2003 14:30:57 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F089511.2010701@attbi.com>
References: <482A3FA0050D21419C269D13989C6113D069EA@lavender-fe.eng.netapp.com>	 <1057015133.21354.44.camel@themachine.sanera.net>	 <shshe67xeyd.fsf@charged.uio.no> <1057088426.26307.0.camel@themachine.sanera.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"Lever, Charles" <Charles.Lever@netapp.com>,
	neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc53.comcast.net ([204.127.198.39] helo=rwcrmhc13.comcast.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ZH5M-0006RH-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Jul 2003 14:30:16 -0700
To: Edward Roper <eroper@wanfear.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Yikes!  Absolutely not!  Its way dangerous, particularly since its not immediately
detectable that you've lost data if the server reboots.  Of course, these 
problems are
based on an complex if condition - if data has been written across the wire, and 
if the
client has received the async response, and if the server reboots while the data is
still in its own caches -  but all you need is one time, and you're toast.

Tom

Edward Roper wrote:

> So in theory running nfs async is no more dangerous than using a local
> app that calls close() without fsync()?
> 
> On Mon, 2003-06-30 at 17:34, Trond Myklebust wrote:
> 
>>>>>>>" " == Edward Roper <eroper@wanfear.com> writes:
>>>>>>>
>>     > Perhaps local close() calls don't actually commit to disk?
>>
>>man 2 close
>>   (and read the NOTES)
>>
>>and then
>>
>>man 2 fsync
>>
>>Cheers,
>>  Trond
>>
> 
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email sponsored by: Free pre-built ASP.NET sites including
> Data Reports, E-commerce, Portals, and Forums are available now.
> Download today and enter to win an XBOX or Visual Studio .NET.
> http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 


-- 
Tom McNeal
(650)906-0761(cell)
(650)964-8459(fax)
Email: trmcneal@attbi.com



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
