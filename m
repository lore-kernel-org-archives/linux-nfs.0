From: Danny Smith <dannys@cinesite.co.uk>
Subject: Re: Adapter teaming
Date: Mon, 06 Jan 2003 17:20:16 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E19BAD0.6060207@cinesite.co.uk>
References: <17110141.1041869610713.JavaMail.www-data@moksha.oddpost.com> <3E19B71F.6060905@emageon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Joseph Marshall <joseph@oddpost.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Vavl-0005en-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Jan 2003 09:20:54 -0800
To: Brian Tinsley <btinsley@emageon.com>
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

I've seen similar results when the teaming is misconfigured on the 
switch, and hence losing packets (half of them in my case).
A quick ping should show that up fairly quickly.
Generally the bonding code works well for us.

Brian Tinsley wrote:

> Yes, we use both the Intel driver (iANS) and the stock bonding driver 
> on our NFS servers and have had no problems. More specifics on your 
> configuration would help.
>
>
> Joseph Marshall wrote:
>
>> Has anyone had any success using NFS on a server that is also doing 
>> Adapter teaming?  For some reason when if I have adapter teaming 
>> set-up and an NFS share mounted my entire server will "lock-up".  If 
>> I turn adpater teaming off, the NFS mount works fine.  Any insight 
>> would be greatly appreciated.   
>> Joe 
>
-- 
Danny Smith
Senior Systems Administrator, Cinesite (Europe) Ltd
020 7973 4000 - x4055    /    dannys@cinesite.co.uk




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
