From: Chris Jensen <chris-nfs@drspirograph.com>
Subject: Re: Stale file handle
Date: Tue, 4 Feb 2003 10:44:44 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302041044.45333.chris-nfs@drspirograph.com>
References: <200302031903.53937.chris-nfs@drspirograph.com> <shslm0xcx68.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta05bw.bigpond.com ([139.134.6.95])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fqAp-0001qJ-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 15:38:47 -0800
Received: from chris ([144.135.24.72]) by mta05bw.bigpond.com
          (Netscape Messaging Server 4.15 mta05bw Jul 16 2002 22:47:55)
          with SMTP id H9RB0F00.GIB for <nfs@lists.sourceforge.net>; Tue,
          4 Feb 2003 09:38:39 +1000
To: nfs@lists.sourceforge.net
In-Reply-To: <shslm0xcx68.fsf@charged.uio.no>
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

On Tue, 4 Feb 2003 12:26 am, Trond Myklebust wrote:
> >>>>> " " == Chris Jensen <chris-nfs@drspirograph.com> writes:
>      > What's going on here? I'm tearing my hair out!
>
> Nobody will be able to figure that out until you give a description of
> your setup.

The server is on linux, kernel 2.4.20, nfs-utils 1.0.1, compiled with gcc 
2.95.2.1, glibc 2.2.3
All of these were compiled from source, nfs-utils was configured with
./configure  --enable-nfsv3 --enable-secure-statd --prefix=/usr

The clients were default setups of RedHat 7.3 and OpenBSD 3.2, which were 
actually VMWare Virtual Machines running on the server.
The server name resolution is being done via the hosts file on the client.
The clients were DHCP clients.
I'd simply used
mount server:/mnt/data /mnt
(trying both IP and name for server)
Then I tried both hard and soft mounts, and forcing to nfsvers 2 and  3

What further information do you need? Like I said before, I couldn't find 
anything significant in the logs (client or server).

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
