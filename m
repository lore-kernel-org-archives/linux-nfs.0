From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: fsid/fileid -> filename
Date: 27 Jan 2003 00:37:04 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsn0ln5vq7.fsf@charged.uio.no>
References: <20030126205429.A26053@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Christian Reis <kiko@async.com.br>
In-Reply-To: <20030126205429.A26053@blackjesus.async.com.br>
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

>>>>> " " == Christian Reis <kiko@async.com.br> writes:

     > One thing that would help a lot while debugging using ethereal
     > is knowing how to look at the NFS requests and seeing what
     > files are being accessed. However, the packets captured only
     > contain the fsid and fileid, and I don't know how to get from
     > them to the filename. Is there a way of finding this out? Some
     > special /proc entry?

The fileid is usually identical to` the inode number 'ls -i'.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
