From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] knfsd: Correct reserved reply space for read requests.
Date: Thu, 30 Mar 2006 02:17:31 -0500
Message-ID: <1143703051.8129.2.camel@lade.trondhjem.org>
References: <20060330165307.25307.patches@notabene>
	 <1060330055350.25337@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751050AbWC3HSE@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060330055350.25337@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2006-03-30 at 16:53 +1100, NeilBrown wrote:
> Single patch for nfsd in 2.6.16.  As the comment say, it is sensible
> for this to sit in -mm for a while just in case.
> 
> ### Comments for Changeset
> 
> NFSd makes sure there is enough space to hold the maximum possible
> reply before accepting a request.  The units for this maximum is
> (4byte) words.  However in three places, particularly for read
> request, the number given is a number of bytes.
> 
> This means too much space is reserved which is slightly wasteful.
> 
> This is the sort of patch that could uncover a deeper bug, and it is
> not critical, so it would be best for it to spend a while in -mm before going in to mainline.
> 
> Discovered-by: "Eivind  Sarto" <ivan@kasenna.com>
> 
> Cc: "Eivind  Sarto" <ivan@kasenna.com>
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./fs/nfsd/nfs3proc.c |    2 +-
>  ./fs/nfsd/nfs4proc.c |    2 +-
>  ./fs/nfsd/nfsproc.c  |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff ./fs/nfsd/nfs3proc.c~current~ ./fs/nfsd/nfs3proc.c
> --- ./fs/nfsd/nfs3proc.c~current~	2006-03-30 16:48:30.000000000 +1100
> +++ ./fs/nfsd/nfs3proc.c	2006-03-30 16:48:58.000000000 +1100
> @@ -682,7 +682,7 @@ static struct svc_procedure		nfsd_proced
>    PROC(lookup,	 dirop,		dirop,		fhandle2, RC_NOCACHE, ST+FH+pAT+pAT),
>    PROC(access,	 access,	access,		fhandle,  RC_NOCACHE, ST+pAT+1),
>    PROC(readlink, readlink,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+NFS3_MAXPATHLEN/4),
> -  PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE),
> +  PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE/4),

Hmm... Wouldn't it be safer to use XDR_QUADLEN()? I doubt that we will
ever set a NFSSVC_MAXBLKSIZE that is not divisible by 4, but...

>    PROC(write,	 write,		write,		fhandle,  RC_REPLBUFF, ST+WC+4),
>    PROC(create,	 create,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),
>    PROC(mkdir,	 mkdir,		create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),
> 
> diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
> --- ./fs/nfsd/nfs4proc.c~current~	2006-03-30 16:48:30.000000000 +1100
> +++ ./fs/nfsd/nfs4proc.c	2006-03-30 16:48:58.000000000 +1100
> @@ -973,7 +973,7 @@ struct nfsd4_voidargs { int dummy; };
>   */
>  static struct svc_procedure		nfsd_procedures4[2] = {
>    PROC(null,	 void,		void,		void,	  RC_NOCACHE, 1),
> -  PROC(compound, compound,	compound,	compound, RC_NOCACHE, NFSD_BUFSIZE)
> +  PROC(compound, compound,	compound,	compound, RC_NOCACHE, NFSD_BUFSIZE/4)

Ditto...

>  };
>  
>  struct svc_version	nfsd_version4 = {
> 
> diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
> --- ./fs/nfsd/nfsproc.c~current~	2006-03-30 16:48:30.000000000 +1100
> +++ ./fs/nfsd/nfsproc.c	2006-03-30 16:48:58.000000000 +1100
> @@ -553,7 +553,7 @@ static struct svc_procedure		nfsd_proced
>    PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
>    PROC(lookup,	 diropargs,	diropres,	fhandle,	RC_NOCACHE, ST+FH+AT),
>    PROC(readlink, readlinkargs,	readlinkres,	none,		RC_NOCACHE, ST+1+NFS_MAXPATHLEN/4),
> -  PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE),
> +  PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE/4),
>    PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
>    PROC(write,	 writeargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
>    PROC(create,	 createargs,	diropres,	fhandle,	RC_REPLBUFF, ST+FH+AT),

Cheers,
  Trond
