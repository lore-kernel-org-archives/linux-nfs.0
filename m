From: raven@themaw.net
Subject: Re: NFS and/or autofs hanging on Linux
Date: Sat, 9 Oct 2004 10:34:42 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0410091031520.1370@donald.themaw.net>
References: <8FDC0F9BE1F91D44BE964AA54AAA67B60E51ED7B@wilmexm3.ad.analog.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, Annie Mckeon <anne.bourgeois@analog.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CG7Ix-0001xD-7K
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 19:49:55 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CG7Ij-0003Or-NT
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 19:49:55 -0700
To: "Burke, Alan" <Alan.Burke@analog.com>
In-Reply-To: <8FDC0F9BE1F91D44BE964AA54AAA67B60E51ED7B@wilmexm3.ad.analog.com>
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

On Thu, 7 Oct 2004, Burke, Alan wrote:

> Hi Everyone,
> 
> We have got a problem with NFS hanging with automounter mounts.
> 
> We're running RH8 2.4.20-20.0 kernel
> NFS-utils 1.0.1-2
> Autofs4.1.2 (we must have the /net ability)
> H/W is mixed HP4100's, Dell 2650's, Sun V60 and V65's
> All the machines are in a Sun NIS domain with 700 Sun machines that run
> fine.

Have you patched the kernel with the latest autofs4 patches from 
kernel.org?

You might like to visit Jeff Moyers people page at RedHat to get his 
latest RPMS.

http://people.redhat.com/jmoyer

Ian



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
