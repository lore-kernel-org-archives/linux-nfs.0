From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: Re: Can someone explain me what this error means?
Date: Tue, 22 Mar 2005 15:13:11 +0000
Message-ID: <42403607.4010801@framestore-cfc.com>
References: <4239A9A3.5000109@framestore-cfc.com>	 <1111075730.13215.19.camel@lade.trondhjem.org>	 <200503171737.19660.vincent.roqueta@ext.bull.net> <1111100343.11736.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Vincent Roqueta <vincent.roqueta@ext.bull.net>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDl6L-0007FA-DK
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 07:15:25 -0800
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DDl6J-0004JM-N0
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 07:15:25 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111100343.11736.12.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> to den 17.03.2005 Klokka 17:37 (+0100) skreiv Vincent Roqueta:
> 
> 
>>The kernel is the 2.4.20, using the e1000 driver... That looks like the bug I 
>>had with UDP fragmentation? I used the same driver!
> 
> 
> Possibly, but there are a bunch of patches that went into 2.4.21 that
> look like they might be relevant:
> 
> v2.4.22-pre1:
>   o kNFSd: TCP nfsd connection hangs when partial record header is
> received
>   o kNFSd: Make sure an early close on a nfs/tcp connection is handled
> properly
> 
> I would first try to reproduce on a newer kernel.

Hiya,

I upgraded to 2.4.25 and this fixed the problem.

Thanks for everyone's help.

-- 
Johan van den Dorpe


-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
