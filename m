From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Re: Root Over NFS Memory Problem
Date: Thu, 4 Mar 2004 16:06:48 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200403041606.48365.bernd-schubert@web.de>
References: <1078409937.3882.10.camel@nick0.seakr.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyuX3-0007AX-CV
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 07:13:05 -0800
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AyuR7-0002Bq-0u
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 07:06:57 -0800
Received: from [80.140.2.23] (helo=bathl.lan.fli4l)
	by smtp.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.99 #605)
	id 1AyuQz-0005lN-00
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 16:06:50 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1078409937.3882.10.camel@nick0.seakr.com>
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

On Thursday 04 March 2004 15:18, Nick Couchman wrote:
> > We are running currently 43 system over a nfs root filesystem and
> > none of those systems is suffering from such memory leak. So I
> > really don't think this is a vanilla kernel issue. If you are sure >
>
> that its the kernel, try without OpenMosix and other patches.
>
> > Cheers,
> >        Bernd
>
> Two things: 1) What version of the kernel are you running?  

Currently 2.4.24 and 2.4.25, but we have had every kernel version since 2.4.18 
except 2.4.22 since it had NFS-bugs (clients permanentely reported server not 
responding).

> 2) We have 
> another Linux box running the same kernel, but it is not booting
> root-over-NFS, it is using the local hard drive.  This machine does not
> "leak" memory.  

Is this machine also using OpenMosix? 

> Other ideas?  Could it be portmap? 

Portmap is a userspace program, I think memory leakage in userspace is easy to 
detect using top, isn't it?

Well, I don't thinkg that its important, we currently mount the nfs-root 
directory from an initrd and not directly from the kernel nfs-root-mount 
functions. However until 2.4.20 we also used the direct approach and had no 
problems. Sorry, no further ideas.

Bernd


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
