From: Chris Jensen <chris-nfs@drspirograph.com>
Subject: Re: Stale file handle
Date: Tue, 4 Feb 2003 12:16:56 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302041216.56567.chris-nfs@drspirograph.com>
References: <200302031903.53937.chris-nfs@drspirograph.com> <shsznpcopqe.fsf@charged.uio.no> <20030203194446.K3318@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta03bw.bigpond.com ([139.134.6.86])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18frc2-0000un-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 17:10:58 -0800
Received: from chris ([144.135.24.81]) by mta03bw.bigpond.com
          (Netscape Messaging Server 4.15 mta03bw Jul 16 2002 22:47:55)
          with SMTP id H9RFA100.15U for <nfs@lists.sourceforge.net>; Tue,
          4 Feb 2003 11:10:49 +1000
To: nfs@lists.sourceforge.net
In-Reply-To: <20030203194446.K3318@redhat.com>
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

On Tue, 4 Feb 2003 11:44 am, Benjamin LaHaise wrote:
> On Tue, Feb 04, 2003 at 01:26:33AM +0100, Trond Myklebust wrote:
> > What type of filesystem are you using on the server?
>
> I've managed to trigger a stale file handle error by accessing a file on
> the server via a hardlink in a directory that is outside of the exported
> path on ext2...

That's not what's happening in my case, however I am referencing the file on 
the share via a symlink on a local file system.

ie
mount server:/mnt/data /mnt
/usr/src/sources -> /mnt/sources
tar -zxvf /usr/src/sources/apps/somefile.tar.gz

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
