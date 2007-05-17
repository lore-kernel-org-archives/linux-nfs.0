From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC, PATCH 7/14] knfsd: export svc_sock_enqueue,
	svc_sock_received
Date: Thu, 17 May 2007 17:45:18 +1000
Message-ID: <20070517074518.GF27247@sgi.com>
References: <20070516192425.GM9626@sgi.com>
	<20070516211703.GF18927@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@sgi.com>, Peter Leckie <pleckie@melbourne.sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hoafs-0003AX-Ur
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:45:25 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Hoafv-00042D-NW
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:45:27 -0700
In-Reply-To: <20070516211703.GF18927@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, May 16, 2007 at 05:17:03PM -0400, J. Bruce Fields wrote:
> On Thu, May 17, 2007 at 05:24:25AM +1000, Greg Banks wrote:
> > 
> > Export svc_sock_enqueue() and svc_sock_received() so they
> > can be used by sunrpc server transport implementations
> > (even future modular ones).
> 
> Have you thought about how you'll handle the reference counting in the
> modular case?

Yes, but only thought not experimented nor discussed.  I was planning
to add a new file to /proc/fs/nfsd roughly analagous to the ports and
versions files, where the init script could write a string to indicate
which transports are enabled or disabled.  Transports would be managed
in a global list of structures analagous to struct xprt_type in Chuck's
client patches.  Enabling from userspace would search this list, try
a module load on failure, and bump the refcount.  Disabling would
shut down all svc_sock belonging to the transport type, then drop
the module refcount.  Neither traffic from clients nor creation of
svc_socks would affect the module refcount.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
