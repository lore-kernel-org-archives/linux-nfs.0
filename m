From: Neil Horman <nhorman@redhat.com>
Subject: Re: should NLM locks send notifications after nfsd crash
Date: Fri, 1 Apr 2005 07:58:08 -0500
Message-ID: <20050401125808.GC6555@hmsendeavour.rdu.redhat.com>
References: <20050331131327.GB1328@hmsendeavour.rdu.redhat.com> <1112285953.12388.17.camel@lade.trondhjem.org> <20050401015641.GB5562@hmsendeavour.rdu.redhat.com> <16972.44651.280877.472381@cse.unsw.edu.au> <1112322501.11284.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Neil Horman <nhorman@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHLjJ-0002AD-SG
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 04:58:29 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DHLjI-0004KG-B0
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 04:58:29 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1112322501.11284.36.camel@lade.trondhjem.org>
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

On Thu, Mar 31, 2005 at 09:28:21PM -0500, Trond Myklebust wrote:
> fr den 01.04.2005 Klokka 12:14 (+1000) skreiv Neil Brown:
> 
> > Stopping the nfsd server threads does not, itself, cause a loss of
> > locking state.
> > However unexporting the filesystems does, and this often accompanies
> > the stopping of the last thread.
> > To be specific:
> >   If the last thread dies due to SIGHUP, or though an explicit setting
> >   of the number of threads to 0:
> >      rpc.nfsd 0
> >   then the filesystems aren't unexported, and locking state remains.
> >   (unless you explicitly exportfs -avu)
> > 
> >   If the last thread dies due to any other signal (KILL, INT, QUIT),
> >   then the filesystems are explicitly unexported which will cause
> >   locking state to be lost.
> 
> 
> Note also that if you do want to trigger a "reboot situation" and have
> lockd go into a grace period, then you can do this by signalling the
> lockd thread using "kill -9". Rather than causing the thread to
> terminate, it will cause it to flush out all locks, and to call the
> function set_grace_period().
> 
> It goes without saying that knfsd itself will not be affected by signals
> to the lockd thread.
> 
> Cheers,
>   Trond
> 
> -- 
> Trond Myklebust <trond.myklebust@fys.uio.no>
> 

Understood.  Thank you Neil, Trond!
Neil

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
