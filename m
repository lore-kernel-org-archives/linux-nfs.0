From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 904217 (2/2): allow enabling TCP without recompile
Date: Tue, 16 Dec 2003 13:16:19 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FDE6AF3.552F659@melbourne.sgi.com>
References: <3FDD6D78.A8FE3262@melbourne.sgi.com> <3FDE6748.7090404@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AW4lD-0006O4-Ro
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 18:16:31 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AW4lD-0008Hj-Hq
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 18:16:31 -0800
To: Steve Dickson <SteveD@RedHat.com>
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

Steve Dickson wrote:
> 
> Greg Banks wrote:
> 
> >These two patches Linux systems to be shipped with CONFIG_NFSD_TCP=y
> >but TCP support disabled at runtime until the sysadmin edits the
> >/etc/sysconfig/nfs file and restarts NFS.  The idea is that TCP
> >support is still disabled by default, but can be enabled with less
> >pain than currently is the case (we have customers who want to try
> >it).
> >
> >
> Why disable it? Since UPD is still mountd's default transport..

This depends on client options outside the scope of the patch, e.g. how
the client's fstab or autofs is configured.  Some clients will try TCP
first and then fall back to UDP when it fails; if the TCP mount suddenly
starts working, that's a visible change.

> >The second patch is for nfs-utils and adds a -t option to nfsd which
> >uses the new nfsctl (added in the first patch) to enable specific
> >transports, and the infrastructure to allow the sysadmin to specify
> >it easily.  Default is to enable UDP only for compatibility.
> >
> >
> This seems a bit messy.... Why not just turn on TCP and have
> nfsd listen on both types of transports?

I don't want to perturb the way in which bits flow across the wire
without the sysadmin's explicit intervention.  This is purely a
support issue, not a technical one.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
