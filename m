From: "Lorn Kay" <lorn_kay@hotmail.com>
Subject: Re: Re: NFS as a Cluster File System.
Date: Fri, 10 Jan 2003 17:19:52 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F100FR0rmTIVvLVKi3s0000ec53@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: alanr@unix.sh, nfs@lists.sourceforge.net, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f100.law11.hotmail.com ([64.4.17.100] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18X2rV-0000mP-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 09:22:29 -0800
To: trond.myklebust@fys.uio.no
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

>
>     >> NFS V3 and before have problems with "cache coherency".  That
>     >> is, the different nodes in the cluster are not guaranteed to
>     >> see the same contents.
>
>      > I think this can be resolved with the "noac" mount option
>      > (prior to V4).
>
>Nope. It can only be resolved using file locking.
>
>Cheers,
>   Trond
>

Meaning if you don't lock a file and just read it you may not see the what 
another client has written to it, or is that not an issue because the other 
client will have locked and then unlocked the file when it is done making 
changes?

Thanks,

--K

_________________________________________________________________
MSN 8 with e-mail virus protection service: 2 months FREE* 
http://join.msn.com/?page=features/virus



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
