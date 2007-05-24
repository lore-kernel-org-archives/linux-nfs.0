From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Thu, 24 May 2007 18:35:08 +1000
Message-ID: <20070524083508.GD31072@sgi.com>
References: <20070523140901.GG14076@sgi.com>
	<1179931410.9389.144.camel@trinity.ogc.int>
	<20070523145557.GN14076@sgi.com>
	<1179932586.6480.53.camel@heimdal.trondhjem.org>
	<20070523162908.GP14076@sgi.com>
	<EXNANE01KMnap2SAWQ800000a62@exnane01.hq.netapp.com>
	<1179945437.6707.36.camel@heimdal.trondhjem.org>
	<EXNANE01FRaqbC8wSA100000a63@exnane01.hq.netapp.com>
	<1179950482.6707.51.camel@heimdal.trondhjem.org>
	<EXNANE01XvpFVjCRGry00000a64@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Peter Leckie <pleckie@melbourne.sgi.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hr8n4-0002lN-JU
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 01:35:23 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Hr8n6-0004BB-2V
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 01:35:25 -0700
In-Reply-To: <EXNANE01XvpFVjCRGry00000a64@exnane01.hq.netapp.com>
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

On Wed, May 23, 2007 at 05:00:03PM -0400, Talpey, Thomas wrote:
> At 04:01 PM 5/23/2007, Trond Myklebust wrote:
> >On Wed, 2007-05-23 at 14:59 -0400, Talpey, Thomas wrote:
> >> Personally, I'm not completely sure I see the problem here. If an RDMA
> >> adapter is going out to lunch and hanging what should be a very fast
> >> operation (the RDMA Read data pull), then that's an adapter problem
> >> which we should address in the adapter layer, or via some sort of interface
> >> hardening between it and RPC. Trying to push the issue back down the RPC
> >> pipe to the sending peer seems to me a very unworkable solution.
> >
> >AFAIK, the most common reason for wanting to defer a request is if the
> >server needs to make an upcall in order to talk to mountd,

This is the original and AFAICT only reason svc_defer() is called.

> > or to resolve
> >an NFSv4 name using idmapd.

It seems the idmap code deliberately circumvents the asynchronous
defer/revisit behaviour, and has code which blocks the calling thread
for up to 1 second in the case of a cache miss and subsequent upcall
to userspace.  After 1 second it gives up.

So with NFSv4, if the LDAP server goes AWOL, some portion of NFS
calls will experience multiple-second delays, 1 second for each user
and group name in the call.  Wonderful.

> > I don't think you really want to treat
> >hardware failures by deferring requests...

Agreed, the right way to handle hardware issues is disconnect.

> Well, the most common occurrence would be a lost conenction, this
> would prevent sending even nfserr_jukebox. I'm suggesting that if
> we're concerned about using nfsd thread context to pull data, then
> we should also be concerned about calling into filesystems, which might
> hang on their storage adapters, or whatever just as easily.

Two comments.

Firstly, some of us *are* concerned about those issues

http://marc.info/?l=linux-nfs&m=114683005119982&w=2
http://oss.sgi.com/archives/xfs/2007-04/msg00114.html

Secondly, there's a fundamental difference between blocking
for storage-side reasons and blocking for network-side reasons.

The former is effectively internal(*) to the NAS server and reflects
it's inherent capability to provide service.  If the disks are broken,
then mechanisms internal to the server host (RAID, failover, whatever)
take care of this.  So blocking (for short periods) in the filesystem
because the disks are fully loaded is fine, in fact this is the
fundamental purpose of the nfsd threads.

The latter is external to the server and is subject to the vagaries
of client machines, which can have hardware faults, software flaws,
or even be malicious and attempting to crash the server or lock it up.
Here we have a service boundary which the knfsd code needs to enforce.
We need firstly to protect the server from the effects of bad clients
and secondly to protect other clients from the effects of bad clients.

(*) Here I am ignoring the case of NFS exporting a clustered fs

> Basically, I'm saying there shouldn't be any special handling for the
> RDMA Reads used to pull write data. In the success case, they happen
> quite rapidly (at wire speed), and in the failure case, there isn't any
> peer to talk to anyway. So what are we protecting?

All the *other* clients who can't get any service, or get slower
service, because many nfsd threads are blocked.  The problem here
is fairness between multiple clients in the face of a few greedy,
broken or malicious ones.

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
