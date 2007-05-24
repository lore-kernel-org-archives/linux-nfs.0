From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Thu, 24 May 2007 09:45:52 -0400
Message-ID: <EXNANE01WhMnU5JzUID00000a6e@exnane01.hq.netapp.com>
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
	<20070524083508.GD31072@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Peter Leckie <pleckie@melbourne.sgi.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrDeB-0000Ia-RY
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 06:46:32 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrDeD-0002op-J8
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 06:46:34 -0700
In-Reply-To: <20070524083508.GD31072@sgi.com>
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
	<20070524083508.GD31072@sgi.com>
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

At 04:35 AM 5/24/2007, Greg Banks wrote:
>So with NFSv4, if the LDAP server goes AWOL, some portion of NFS
>calls will experience multiple-second delays, 1 second for each user
>and group name in the call.  Wonderful.
...
>> we should also be concerned about calling into filesystems, which might
>> hang on their storage adapters, or whatever just as easily.
>
>Two comments.
>
>Firstly, some of us *are* concerned about those issues

Great! I like the idea of a nonblocking FS API that nfsd can use, though
a full asynchronous API (with a cancel capability) might be better. This
is just an aside to the current discussion, of course.


>Secondly, there's a fundamental difference between blocking
>for storage-side reasons and blocking for network-side reasons.
>...
>The latter is external to the server and is subject to the vagaries
>of client machines, which can have hardware faults, software flaws,
>or even be malicious and attempting to crash the server or lock it up.
>Here we have a service boundary which the knfsd code needs to enforce.
>We need firstly to protect the server from the effects of bad clients
>and secondly to protect other clients from the effects of bad clients.

Oh, absolutely the knfsd needs to have some sort of hardening from this
type of issue. I think a timer on any RDMA Read wire operation would be
very well advised. And, if the timer fires, the entire WRITE operation would
obviously be aborted, this in turn would naturally indicate the knfsd should
disconnect (terminating all other client operations), because that is the only
way to abort an in-progress RDMA.

My concern is using nfserr_jukebox to somehow manage the queue of RDMA
Read operations the server is processing, as was originally suggested.
You can think of the adapter's RDMA Read engine as a very short work
queue - it will generally be quite busy with work queued. The good news is,
it is a very fast engine. So, I think it is reasonable to use a timeout of just
a few seconds once an operation begins. But I don't think it's reasonable to
somehow limit the amount of WRITEs the server should handle in order to
simplify this.

>All the *other* clients who can't get any service, or get slower
>service, because many nfsd threads are blocked.  The problem here
>is fairness between multiple clients in the face of a few greedy,
>broken or malicious ones.

So, the attack you're suggesting is a client would issue a large number
of chunked WRITES, and then delay the resulting RDMA Reads that the
server issued to fetch the data, in an attempt to tie up all the server
threads? That would be a challenging attack to implement, but I guess
I would say there are several things that will protect us here.

- the client can only send as many WRITES as he has credits to send,
this is a server-managed limit
- the server is free to leave client operations in their receive buffers
unprocessed until it cares to execute them, as is done for tcp etc.
- the client can't block operations to other connections (clients), i.e
the RDMA Read limits are per-connection only.
- any failure such as an RDMA Read timer expiration will cause the
connection to be lost, immediately freeing up all threads servicing
that client.

Bottom line, my feeling is that adding a timeout to the RDMA Read
requests we make of the local adapter is all we need to implement
the necessary protection. If we want to address the situation for
N nfsd threads to fairly service a much larger number of arriving client
requests, that's a much deeper issue (and a good one, but not an
RDMA one).

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
