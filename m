From: Rudy Zijlstra <rudy@edsons.demon.nl>
Subject: Re: Kernel BUG
Date: Sat, 23 Dec 2006 00:46:30 +0100
Message-ID: <458C6E56.3070700@edsons.demon.nl>
References: <458BC8AE.2030507@edsons.demon.nl>
	<1166794920.32117.42.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs <nfs@lists.sourceforge.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gxu64-0006U4-Au
	for nfs@lists.sourceforge.net; Fri, 22 Dec 2006 15:46:40 -0800
Received: from post-25.mail.nl.demon.net ([194.159.73.195])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gxu63-0002CZ-0U
	for nfs@lists.sourceforge.net; Fri, 22 Dec 2006 15:46:40 -0800
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1166794920.32117.42.camel@twins>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Peter Zijlstra wrote:

>On Fri, 2006-12-22 at 12:59 +0100, Rudy Zijlstra wrote:
>  
>
>>Hi,
>>
>>I have a system where whenever i trigger a ongoing consistent NFS load i 
>>get the following kernel BUG:
>>
>>----------
>>kernel BUG at mm/truncate.c:311!
>>    
>>
>
>Lotsa changes there:
>try these:
> http://client.linux-nfs.org/Linux-2.6.x/2.6.19/linux-2.6.19-NFS_ALL.dif
>
>And:
>  http://lkml.org/lkml/2006/12/19/279
>
>  
>
Thanks, i have now a 2.6.19.1 patched with the above NFS_ALL patchset 
running under load since about 17:00 and still going strong. So seems to 
have solved the problem!

Also, performance seems to have significantly increased. I am testing 
this with MythTv with the storage over NFS. With HD LiveTV (which  is 
what i use to test this), this translates into about 43Mbps total load, 
from almost 15Mbps video stream which is present 3x on the ethernet:
1/ from card to NFS disk
2/ read from NFS disk
3/ stream to viewer app.

Doing this with HD streams before the patch set resulted in regular 
picture hickups. No hickups visible anymore (that i have seen, i have 
not been present all this time).

Regards,

Rudy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
