From: Philippe Troin <phil@fifi.org>
Subject: Re: SM_UNMON again -> kernel
Date: 18 Jul 2003 20:26:50 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87n0fb42o5.fsf@ceramic.fifi.org>
References: <20030711061615.GA1924@quasar.nro.au.com>
	<shsr84x768e.fsf@charged.uio.no> <87smpbkt55.fsf@ceramic.fifi.org>
	<shs8yr2h2jr.fsf@charged.uio.no> <87k7aml330.fsf@ceramic.fifi.org>
	<shsptkdij1a.fsf@charged.uio.no> <87vfu0ej5k.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19diNd-0007P4-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Jul 2003 20:27:29 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <87vfu0ej5k.fsf@ceramic.fifi.org>
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

Philippe Troin <phil@fifi.org> writes:

> Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
> > >>>>> " " == Philippe Troin <phil@fifi.org> writes:
> > 
> >      > On machine #1: ceramic rpc.statd[30693]: Received erroneous
> >      > SM_UNMON request from ceramic for 216.27.190.149
> > 
> >      > On machine #2: tantale rpc.statd[18416]: Received erroneous
> >      > SM_UNMON request from tantale for 216.27.190.148
> > 
> > OK. Hang on... The above looks more like stale entries due to somebody
> > having permanently switched off a server on which ceramic/tantale were
> > holding locks.
> 
> Nope, the machines have been rebooted...
>  
> > Could you check on 'ceramic', and 'tantale' if they don't have entries
> > for 216.27.190.149 and 216.27.190.148 respectively in /var/lib/nfs/sm
> > or /var/lib/nfs/sm.bak?
> 
> They have indeed very old files there that were removed.
> 
> > Another mistake that can cause the above errors is if the sysman has
> > made those 2 directories NFS shared between different clients. (Not a
> > good idea...)
> 
> No, that not the case. But I can see why it would wreak havoc.
> 
> Anyways, this is what I did:
> 
>  - I shut down all boxes interacting via NFS.
> 
>  - When booting them up, I switched to single-user mode and:
> 
>      * wiped /var/lib/nfs/mtab
> 
>      * removed any files in /var/lib/nfs/sm{,.bak}
> 
> And we'll see if the message shows up again.

And it did...

I still see the same messages over and over again.

Phil.


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
