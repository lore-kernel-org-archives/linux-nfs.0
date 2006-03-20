From: Aurelien Degremont <aurelien.degremont@cea.fr>
Subject: Re: NFS superblock sharing implies mount flags bug
Date: Mon, 20 Mar 2006 14:20:05 +0100
Message-ID: <441EAC05.7020903@cea.fr>
References: <200603151038.LAA21392@styx.bruyeres.cea.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net,
	Jacques-Charles Lafoucriere <jc.lafoucriere@cea.fr>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: trond.myklebust@fys.uio.no, viro@zeniv.linux.org.uk
In-Reply-To: <200603151038.LAA21392@styx.bruyeres.cea.fr>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Nobody is interested by this issue ?
It could be easily reproduced. All recent versions are concerned.

Aurelien


Aurelien Degremont wrote:
> Hello
> 
> I'm facing incorrect using of mount flags when dealing with NFS mounts 
> and I think it could be seen as a bug.
> 
> The error occurs when mounting the same NFS export many times, on the 
> same machine but *with different mount flags*, particularly concerning 
> RO/RW flags.
> 
> As the NFS client code re-uses superblocks when it detects that it is 
> the same export (same server/same port/same exported directory) and that 
> the read-only flag is managed as a per-superblock flag, if a NFS exports 
> is mounted a second time, the superblock of the first mount is re-used 
> and the specified mount flag is ignored.
> 
> # mount foo:/bar /bar_ro -o ro
> # mount foo:/bar /bar_rw -o rw
> $ touch /bar_rw/bar
> touch: cannot touch `/bar_rw/bar': Read-only file system
> 
> Ideally, the best solution to fix this is to move the RDONLY flag from 
> its per-superblock basis to a per-mountpoint (vfsmount) basis. I do not 
> know is there is a something that prevent that except that this implies 
> many changes as many codes do not use macros but access s_flags directly.
> 
> It seems quite clear that the superblock sharing couldn't be changed (to 
> avoid incoherency, inode aliasing and so on...) ?
> 
> Do you have a (better) solution ?
> I can help if needed.
> 
> 
> Cordially
> 


-- 
Aurelien Degremont
CEA/DAM - DIF/DSSI/SISR
