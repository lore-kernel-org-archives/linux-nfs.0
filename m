From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [autofs] Server/client mismatch over status of a mount ...
Date: Wed, 19 Feb 2003 11:16:44 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15955.22924.593942.167698@charged.uio.no>
References: <3E50EC51.6022D3A7@moving-picture.com>
	<20030217152036.GA23116@terminus.zytor.com>
	<shsheb2lxde.fsf@charged.uio.no>
	<3E510686.6899E7BE@moving-picture.com>
	<15953.2794.981629.182213@charged.uio.no>
	<3E5120C4.9C03C7A6@moving-picture.com>
	<3E5265EA.14C644F5@moving-picture.com>
	<1199.195.252.45.39.1045648619.squirrel@www.zytor.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <james-p@moving-picture.com>,
    <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lRHk-0008LB-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 02:17:04 -0800
To: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <1199.195.252.45.39.1045648619.squirrel@www.zytor.com>
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

>>>>> " " == H Peter Anvin <hpa@zytor.com> writes:

     > A user can come in between the test and the umount request, and
     > autofs depends on /bin/umount signalling error without harmful
     > side effects.

Right. Unfortunately harmful side effects are almost inevitable here
since stateful operations over RPC are inherently race-prone (support
for out-of-order message delivery just isn't part of the state game
8-)).
All we can do is reduce the number of races to a minimum and
hopefully fix knfsd at some point in the near future.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
