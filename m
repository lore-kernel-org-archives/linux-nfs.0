From: "Amir Hermelin" <amir@montilio.com>
Subject: RE: remounting with a different blocksize
Date: Wed, 17 Sep 2003 16:04:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00ae01c37d24$b34f01e0$1301a8c0@CARTMAN>
References: <3F683E15.6010708@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="windows-1255"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zc09-0005jV-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 06:05:46 -0700
Received: from sphere.barak.net.il ([212.150.48.98])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zc09-0003wJ-Bf
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 06:05:45 -0700
To: "'Steve Dickson'" <SteveD@RedHat.com>
In-Reply-To: <3F683E15.6010708@RedHat.com>
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

Steve,
I turn on nfsd debugging using '/sbin/sysctl -w =
sunrpc.nfsd_debug=3D65535'.
There I see that the READ requests come in 4k blocks.  Other than that =
the
operation works fine (since both the client and the server agree on this
4k).

Amir.


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Steve Dickson
Sent: =E3 17 =F1=F4=E8=EE=E1=F8 2003 12:57
To: Amir Hermelin
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] remounting with a different blocksize



Amir Hermelin wrote:

>I'm using RH Linux 2.4.20 on both machines.  When I first mount one of=20
>the machines with a 4k read/write blocksize, the READ requests are 4K=20
>bytes. However, when I umount and then mount again with read/write=20
>blocksize of 8K, the READ requests are still 4K bytes.
>
>Any ideas on how I can properly change the blocksizes?
>
I just ran a quick experiment on with my 2.4.20 kernel and everything =
seem
to work as expected... How are you verifying the blocks sizes?

SteveD.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf _______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
