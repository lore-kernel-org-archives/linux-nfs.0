From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Root Over NFS Memory Problem
Date: Wed, 3 Mar 2004 22:13:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200403032213.24892.bernd-schubert@web.de>
References: <1078336680.31825.19.camel@nick0.seakr.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aydxu-0001bV-Qn
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 13:31:42 -0800
Received: from smtp03.web.de ([217.72.192.158] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AydsP-0004Do-6T
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 13:26:01 -0800
Received: from [80.140.1.211] (helo=bathl.lan.fli4l)
	by smtp.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.99 #605)
	id 1AydgG-0006bc-00
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 22:13:29 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1078336680.31825.19.camel@nick0.seakr.com>
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

On Wednesday 03 March 2004 18:58, Nick Couchman wrote:
> I'm trying to run a few clients using NFS for the root filesystem.  I'm
> having a problem with what appears to be a memory "leak" (I'm not sure
> it's actually a leak, but for all intents and purposes, it is).  What
> happens is that I lose 8k of free memory every time I run a command.
> For example, if I repeatedly run the "free" command, the free memory
> will drop 8k each time I run it.  If I instead run "free -s 1" (telling
> free to update at 1 second intervals), it drops a couple of times and
> then levels out.  The problem is bad enough that one of the clients ran
> out of memory (swap - on a local hard drive - and physical RAM) the
> other night and "kernel panicked".  The clients are running kernel
> version 2.4.22 with the OpenMosix patch (2.4.22 seems to be the latest
> "stable" OpenMosix version).  Has anyone run across this problem
> before?  Any ideas what I can do to fix it?  Is it a known NFS bug in
> 2.4.22 that is fixed in later versions?  (I'm about to try another
> version of the kernel which might give me an answer to that, but I
> thought I'd ask).
>

We are running currently 43 system over a nfs root filesystem and none of 
those systems is suffering from such memory leak. So I really don't think 
this is a vanilla kernel issue. If you are sure that its the kernel, try 
without OpenMosix and other patches.

Cheers,
	Bernd


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
