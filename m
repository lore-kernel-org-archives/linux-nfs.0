From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS over TCP
Date: 28 May 2003 14:33:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsn0h7l08u.fsf@charged.uio.no>
References: <20030527234058.81598.qmail@web21003.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19L0D2-00059o-00
	for <nfs@lists.sourceforge.net>; Wed, 28 May 2003 05:39:12 -0700
To: David Myer <davidmyer800@yahoo.com>
In-Reply-To: <20030527234058.81598.qmail@web21003.mail.yahoo.com>
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

>>>>> " " == David Myer <davidmyer800@yahoo.com> writes:

     > 1) Doing a few mount operations, I noticed that
     > sometimes it uses V3 GETATTR call and sometimes it uses V2
     > GETATTR call, how does client ( or server ) decide witch
     > version to use ? Strange enough, in case it did use V3 GETATTR,
     > the prior GETPORT is V2.. does this make a difference later on
     > ?

The kernel will switch to NFSv2 if v3 is not available. To determine
whether or not v3 is available, the server's portmapper is consulted.

     > 2) In reply to the V2 GETATTR call, server reply to
     > the client socket (port 800) with ACK, then send another packet
     > ( with PSH/ACK flags on ) with requested data to port 799,this
     > causes RST from the client. Anyone seen this behavior of
     > decrementing dest port ( client port number ) by one ?

Huh? TCP is a connection oriented protocol. The server does not get to
choose which port to send a reply to. Are you sure you are not
confusing MOUNT and NFS requests here?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
