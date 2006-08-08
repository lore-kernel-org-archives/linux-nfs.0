From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 003 of 4] Prepare knfsd for support of	rsize/wsize
	of up to 1MB, over TCP.
Date: Tue, 08 Aug 2006 12:12:10 +1000
Message-ID: <1155003129.29877.177.camel@hole.melbourne.sgi.com>
References: <20060807103020.12286.patches@notabene>
	<1060807003515.12391@suse.de>
	<76bd70e30608070604r5da3fefds4fea763336221403@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAH4t-0001Yo-V7
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 19:12:20 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAH4t-00052p-9w
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 19:12:20 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30608070604r5da3fefds4fea763336221403@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2006-08-07 at 23:04, Chuck Lever wrote:
> I know the name NFSSVC_MAXBLKSIZE is historical, but to me it is
> confusing.  It isn't a block size at all, it's really a maximum
> tranfser size, in bytes, right?

NFSSVC_MAXBLKSIZE is the maximum NFS payload size, i.e. the largest
size of file data that can passed in WRITE and returned from READ.
The transfer size (as I understand the term) would be that plus the
NFS and RPC headers, i.e. 65536 bytes for UDP.  So I think the name
is mostly OK.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
