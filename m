From: Philippe Troin <phil@fifi.org>
Subject: Re: Re: [NFS client] NFS locks not released on abnormal process termination
Date: 09 Dec 2003 11:26:48 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87wu95u70n.fsf@ceramic.fifi.org>
References: <EE335453C5C57840823404C684F9F61702417581@exmbx01sj.cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATnXG-0005b4-32
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 11:28:42 -0800
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATnXF-0003QX-ID
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 11:28:41 -0800
To: "Chris Croswhite" <csc@cadence.com>
In-Reply-To: <EE335453C5C57840823404C684F9F61702417581@exmbx01sj.cadence.com>
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

"Chris Croswhite" <csc@cadence.com> writes:

> Philippe,
> 
> What patches are you refering to?

The one in <87llpms8yr.fsf@ceramic.fifi.org> named
linux-2.4.23-nfs-lock-race-2.patch 

Here a link to MARC, since the sourceforge mailing list web page
sucks:

  http://marc.theaimsgroup.com/?l=linux-nfs&m=107095817723325&w=2

Phil.

> -----Original Message-----
> From:	Philippe Troin [mailto:phil@fifi.org]
> Sent:	Tue 09-Dec-03 10:46
> To:	Trond Myklebust
> Cc:	Kenny Simpson; linux-kernel@vger.kernel.org; nfs@lists.sourceforge.net
> Subject:	[NFS] Re: [NFS client] NFS locks not released on abnormal process termination
> Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
> > >>>>> " " == Philippe Troin <phil@fifi.org> writes:
> > 
> >      > From my reading of the patch, it supersedes the old patch, and
> >      > is only
> >      > necessary on the client. Is also does not compile :-)
> > 
> > Yeah, I admit I didn't test it out...
> > 
> >      > Here's an updated patch which does compile.
> > 
> > Thanks.
> > 
> >      > I am still running tests, but so far it looks good (that is all
> >      > locks are freed when a process with locks running on a NFS
> >      > client is killed).
> > 
> > Good...
> 
> I've ran test overnight on four boxen, and no locks were lost.
> I guess you can send this patch to Marcello now.
> 
> I've tested with the enclosed program.
> 
>  
> > There are still 2 other issues with the generic POSIX locking code.
> > Both issues have to do with CLONE_VM and have been raised on
> > linux-kernel & linux-fsdevel. Unfortunately they met with no response,
> > so I'm unable to pursue...
> 
> Can we help? Pointers?
> 
> Phil.
> 
> 
> 
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: SF.net Giveback Program.
> Does SourceForge.net help you be more productive?  Does it
> help you create better code?  SHARE THE LOVE, and help us help
> YOU!  Click Here: http://sourceforge.net/donate/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
