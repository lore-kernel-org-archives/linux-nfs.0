From: Chris Jensen <chris-nfs@drspirograph.com>
Subject: Re: Stale file handle
Date: Tue, 4 Feb 2003 12:46:50 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302041239.22301.chris-nfs@drspirograph.com>
References: <200302031903.53937.chris-nfs@drspirograph.com> <200302041218.31527.chris-nfs@drspirograph.com> <15935.5764.263002.800295@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta01bw.bigpond.com ([139.134.6.78])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fs4z-00073r-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 17:40:53 -0800
Received: from chris ([144.135.24.75]) by mta01bw.bigpond.com
          (Netscape Messaging Server 4.15 mta01bw Jul 16 2002 22:47:55)
          with SMTP id H9RGNX00.4GV for <nfs@lists.sourceforge.net>; Tue,
          4 Feb 2003 11:40:45 +1000
To: nfs@lists.sourceforge.net
In-Reply-To: <15935.5764.263002.800295@charged.uio.no>
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

> Unfortunately FAT filesystems are not very NFS-friendly as they lack a
> reliable way to generate an NFS filehandle. (The NFS filehandle is a
> way of uniquely identifying the file to the server in a manner that
> does not depend on the pathname).
>
> The current implementation in knfsd relies heavily on the file staying
> in the server's 'dentry cache' until the NFS client has finished with
> it. If/when memory pressure forces garbage collection on the dcache,
> the server will lose its mapping between file and NFS filehandle, and
> you will get a 'stale file handle' error being returned to the client.

So is it just a coincidence that this has worked for over a year? I wouldn't 
have thought so, because there have often been times when I have been 
compiling on the server while connecting with a client, wouldn't this have 
placed memory pressure on the server?

-- 
Chris Jensen

Public Key: http://drspirograph.com/public_key/

Wait: Did you know that there's a direct correlation between the decline of
Spirograph and the rise in gang activity?  Think about it.
- Dr Spirograph (The Simpsons)




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
