From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 926917: make knfsd interact cleanly with HSMs
Date: Thu, 31 Mar 2005 11:58:56 +1000
Message-ID: <16971.22880.262928.543410@cse.unsw.edu.au>
References: <20050315074949.GA4541@sgi.com>
	<1112233192.1991.1031.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGoxs-0001Xr-Rs
	for nfs@lists.sourceforge.net; Wed, 30 Mar 2005 17:59:20 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DGoxZ-0002n7-3Y
	for nfs@lists.sourceforge.net; Wed, 30 Mar 2005 17:59:19 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Thursday March 31
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

On Thursday March 31, gnb@melbourne.sgi.com wrote:
> On Tue, 2005-03-15 at 18:49, Greg Banks wrote:
> > This patch seeks to remedy the interaction between knfsd and HSMs by
> > providing mechanisms to allow knfsd to tell an underlying filesystem
> > (which supports HSMs) not to block for reads, writes and truncates
> > of offline files.  It's a port of a Linux 2.4 patch used in SGI's
> > ProPack distro for the last 12 months.  The patch:
> 
> Any news on this patch?  Is it good, bad, ugly, or what?

Obviously I need a better system for keeping track of open
issues... maybe some yellow postit notes would help :-)


Yes, it looks reasonably sane.

I'm not very comfortable about the

+		if (rqstp->rq_vers == 3)

usage.  Shouldn't it be 
+		if (rqstp->rq_vers >= 3)
as presumably NFSv4 would like NFSERR_JUKEBOX returns too.

Also, it assumes an extension to the semantics of IFREG files such
that O_NONBLOCK has a meaning... What exactly is that meaning?
"Returned -EAGAIN if the request will take a long time for some vague
definition of long" ...

Is this new semantic in any way 'standard' or accepted by the
filesystem gurus (e.g. Al Viro)??

NeilBrown



-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
