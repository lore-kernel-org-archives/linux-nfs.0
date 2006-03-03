From: Steven Timm <timm@fnal.gov>
Subject: Re: NFS possible race condition, nfs_unlink vs. d_lookup
Date: Fri, 03 Mar 2006 15:15:25 -0600 (CST)
Message-ID: <Pine.LNX.4.62.0603031514140.6140@snowball.fnal.gov>
References: <Pine.LNX.4.62.0603030955060.11612@snowball.fnal.gov>
 <1141418871.10976.31.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FFHq9-0000sO-AF
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 13:29:33 -0800
Received: from mailgw2.fnal.gov ([131.225.111.12])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FFHq8-0000yw-17
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 13:29:33 -0800
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0IVK00KOTLN9IB@mailgw2.fnal.gov> for nfs@lists.sourceforge.net;
 Fri, 03 Mar 2006 15:15:25 -0600 (CST)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2006030315152530324 for
 <nfs@lists.sourceforge.net>; Fri, 03 Mar 2006 15:15:25 -0600
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0IVK00E01LBLGH@mailgw1.fnal.gov> (original mail from timm@fnal.gov)
 for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 15:15:25 -0600 (CST)
In-reply-to: <1141418871.10976.31.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

On Fri, 3 Mar 2006, Trond Myklebust wrote:

> On Fri, 2006-03-03 at 09:57 -0600, Steven Timm wrote:
>
>> My question.. is the 2.4.21-37 kernel as distributed by Red Hat also
>> vulnerable to this race condition? If so, is there any
>> patch that is available?  The code in dir.c in the 2.4 series
>> kernel is different enough such that this patch won't apply to it.
>
> No idea. Are you saying that RedHat shipped a 2.4.x kernel with RCU
> patches to the vfs before they had been tested in the 2.6.x kernel?

I don't have enough expertise to tell what they have done.  I
can attach the dir.c in question if someone is able to look.
All I know is that we are seeing a similar condition, namely
nfs_safe_remove errors happening on our client, for what
this patch was supposed to fix in the 2.5/2.6 series kernels.
Any help would be appreciated.


Steve Timm


>
> Cheers,
>  Trond
>
>

-- 
------------------------------------------------------------------
Steven C. Timm, Ph.D  (630) 840-8525  timm@fnal.gov  http://home.fnal.gov/~timm/
Fermilab Computing Div/Core Support Services Dept./Scientific Computing Section
Assistant Group Leader, Farms and Clustered Systems Group
Lead of Computing Farms Team


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
