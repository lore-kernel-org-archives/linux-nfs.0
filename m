From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS over TCP reports strange messags on Fedora FC1
Date: Tue, 30 Mar 2004 16:30:03 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080682203.2557.61.camel@lade.trondhjem.org>
References: <41089CB27BD8D24E8385C8003EDAF7AB08483C@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "NFSUserList (E-mail)" <nfs@lists.sourceforge.net>, ops <ops@alexa.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8QoB-0004DX-Ha
	for nfs@lists.sourceforge.net; Tue, 30 Mar 2004 13:30:07 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B8QoB-0006iV-AQ
	for nfs@lists.sourceforge.net; Tue, 30 Mar 2004 13:30:07 -0800
To: Guolin Cheng <guolin@alexa.com>
In-Reply-To: <41089CB27BD8D24E8385C8003EDAF7AB08483C@karl.alexa.com>
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

On Tue, 2004-03-30 at 15:52, Guolin Cheng wrote:
> Hi,
> 
>   I got a strange problem on my newly installed Fedora FC1 box. On the FC1 box'es console I got the following error messages:
> 
>   RPC: bad TCP reclen 0x*********** (non-terminal)
>   RPC: bad TCP reclen 0x*********** (large)
>   ... (same, omitted) ....
> 
> 
>   Any one know why? The nfs function seems working fine...

Could be that someone trying to crash your NFS server. The above is the
sort of output you would see if someone is feeding it random garbage.

Only a tcpdump that catches the offending behaviour could tell...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
