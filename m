From: Chris Jensen <chris-nfs@drspirograph.com>
Subject: Re: Stale file handle
Date: Tue, 4 Feb 2003 11:15:20 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302041115.20608.chris-nfs@drspirograph.com>
References: <200302031903.53937.chris-nfs@drspirograph.com> <shslm0xcx68.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta04bw.bigpond.com ([139.134.6.87])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fqeQ-0006dF-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 16:09:23 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

In addition, the other box that I mentioned that has been working happily with 
the server for over a year, has now shown the problem also.
I had just recently changed the mount options on that box from soft to hard, 
reverting to soft seems to have fixed it.

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
