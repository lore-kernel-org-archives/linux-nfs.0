From: Michael Thomson <michael@canb.auug.org.au>
Subject: Re: AIX and HP NFS client behaviour
Date: Mon, 23 Jun 2003 16:37:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF6A01B.61276BC3@canb.auug.org.au>
References: <3EED1FF7.4EBE7558@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta03bw.bigpond.com ([139.134.6.86])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UKvy-0001LX-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Jun 2003 23:36:10 -0700
Received: from localhost.localdomain ([144.135.24.78]) by
          mta03bw.bigpond.com (Netscape Messaging Server 4.15 mta03bw Jul
          16 2002 22:47:55) with SMTP id HGX8ZS00.C74 for
          <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 16:35:52 +1000
Received: from canb.auug.org.au (ssa14.worldgroup.com [203.2.203.114])
	by localhost.localdomain (8.12.8/8.8.5) with ESMTP id h5N6ZtsY028613
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 16:35:57 +1000
To: nfs@lists.sourceforge.net
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

Hello All,

I posted this question a while back.

We finally worked out what the problem was.  The NFS client
implementation on AIX and HP had a 'flawed' behaviour when porcessing
seek commands.  This caused the large number of writes and commits.  HP
is currently working on a new Client to 'correct' this behaviour.

We were able to change our application space useage to reduce the
'seeks' and make the problem go away.

Thanks for the replies,
Michael.

Michael Thomson wrote:
> 
> Hi all,
> 
> I have been investigating a problem we have been having with some of our
> NFS clients.
> 
> Our setup is a large filesystem on a Linux server running kernel 2.4.20
> with nfs-utils 1.0.1-2, with a number of clients each accessing their
> own export of a portion of this filessystem.
> 
> With the majority of the clients (Linux, Sun, OS390 etc) we get expected
> performance.  All the clients are using NFS version 3.
> 
> With AIX 4 and HP 11.00 we get acceptable performance when just copying
> a file or generating a file from say /dev/zero.  The networking all
> seems OK.  When we actually run some programs that write and read from
> NFS we get terrible performance...
> 
> What I see when running these clients via nfsstat is:
> Version 3: (548087 calls)
> null                    getattr                 setattr
> 0 0%                    610 0%                  6 0%
> lookup                  access                  readlink
> 416 0%                  56 0%                   0 0%
> read                    write                   create
> 530 0%                  273763 49%              33 0%
> mkdir                   symlink                 mknod
> 0 0%                    0 0%                    0 0%
> remove                  rmdir                   rename
> 16 0%                   0 0%                    0 0%
> link                    readdir                 readdir+
> 0 0%                    0 0%                    4 0%
> fsstat                  fsinfo                  pathconf
> 0 0%                    0 0%                    0 0%
> commit
> 272653 49%
> 
> Basically every write is followed by a commit.  When looking at the
> tcpdump for the same run I see the same thing (as I would expect, but
> just wanted to confirm what nfsstat was saying)
> 
> I initially suspected sync/async issues causing constant commits but
> have tried many different combinations and the problem does not change.
> 
> Does anyone have any idea's of what is causing this 1:1 relationship
> between writes amd commits?
> 
> Does anyone know how to correct the behaviour for AIX4 and HP 11 nfs
> clients?
> 
> Thanks in advance for any information.
> Michael Thomson
> 
> -------------------------------------------------------
> This SF.NET email is sponsored by: eBay
> Great deals on office technology -- on eBay now! Click here:
> http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
