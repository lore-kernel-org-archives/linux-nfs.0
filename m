From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: A Question about the 2.4.21 Pathconf patch
Date: Tue, 29 Apr 2003 22:14:18 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EAF317A.2050903@RedHat.com>
References: <3EAE956E.9080205@RedHat.com>	<shs4r4h5l52.fsf@charged.uio.no>	<3EAEC774.20402@RedHat.com>	<shssms1ozz6.fsf@charged.uio.no>	<3EAEEC0D.6040006@RedHat.com> <16047.285.921874.178993@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ah7E-0007Z8-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 19:14:36 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <16047.285.921874.178993@charged.uio.no>
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

Trond Myklebust wrote:

>It does the RPC call at mount time instead, then caches the results.
>
Aha.... I see.... nfs3_proc_fsinfo() does the fsinfo and 
nfs_proc_fsinfo() is
the v2 version (i.e. uses statfs)....  I missed that!!! I guess the naming
got me confused and I didn't expect v2 to even support the notion of 
fsinfo....
It makes sense now... Thanks for straighting that for me..... 

SteveD.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
