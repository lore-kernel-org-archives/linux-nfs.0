From: Brad Barnett <lists@l8r.net>
Subject: Re: NFS corruption in 2.6.18.2?
Date: Wed, 15 Nov 2006 22:37:00 -0500
Message-ID: <20061115223700.23712a4b@be.back.l8r.net>
References: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
	<20061115172947.GM10830@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkY3q-0000aw-Pa
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 19:37:10 -0800
Received: from l8r.net ([206.248.172.29] ident=aliens)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkY3q-0004jY-KS
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 19:37:12 -0800
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
In-Reply-To: <20061115172947.GM10830@fit.vutbr.cz>
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

On Wed, 15 Nov 2006 18:29:47 +0100
Kasparek Tomas <kasparek@fit.vutbr.cz> wrote:

> On Tue, Nov 14, 2006 at 07:09:17PM +0100, Fredrik Lindgren wrote:
> > Hello
> > 
> > We're running a mail system with Linux machines being served by two
> > NetApps. (Debian stable, our "own" kernel off kernel.org)
> > 
> > At present we're running 2.6.13 kernels, we had some corruption issues
> > before that was fixed in 2.6.13. However when we tried to upgrade
> > to 2.6.18.2 the we see corruption again.
> > 
> > pre 2.6.13 the problem seemed to be that the file size was being
> > cached, which meant that sometimes there were blocks of NULL
> > characters in the files.
> > 
> > With 2.6.18.2 we see blocks of NULL chars in the data again, this time
> > it's sometimes in the middle of a message. pre 2.6.13 that didn't
> > happen,
> > then there were just big blocks of NULL chars between two messages. 
> > The only consistent thing is that it only occurs when the 1 machine
> > running 2.6.18.2 (out of 5) has delivered a message to the spool-file.
> > 
> > I don't know if it's relevant, but when checking the NFS stats I see
> > the 2.6.18.2 machine doing almost precisely half the amount of
> > "GetAttr" calls compared to the 2.6.13 machines.
> > 
> > Is this something anyone else has seen?
> > 
> > Also on a side note, the statistics still seem to be using signed
> > values, so we're seeing negative numbers on some stats after some
> > uptime. This is true for both using "nfsstat" and "cat
> > /proc/net/rpc/nfs.
> 
> I have seen this behaviour with kernel 2.6.18 and above up to 19-rc4.
> Reported this, but no response.
> 
> http://lkml.org/lkml/2006/9/28/89
> 

I believe my previous post about NFS root filesystems, and trying to debug
it has to do with this very issue.

I've recently noticed that large files copied via ssh to /tmp on the root
(/ mounted) NFS file system turn out to be corrupt and can not be
untarred.  I have no such issues with these same boxes, non root NFS
mounted, with 2.6.9 and 2.6.8.  I am in the process of compiling 2.6.8
from the same Debian patched sources, in order to do a comparison.

I will let the list know, if my NFS corruption issues disappear.  However,
it seems likely that this is what is causing my boxes to die.... 

I've seen this on current Debian 2.6.18 and 2.6.19 kernel packages....


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
