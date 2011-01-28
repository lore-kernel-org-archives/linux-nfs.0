From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] NFS: NFSv4 readdir loses entries
Date: Fri, 28 Jan 2011 13:39:38 -0500
Message-ID: <1296239978.5464.16.camel@heimdal.trondhjem.org>
References: <20110128173624.3235.74504.stgit@matisse.1015granger.net>
	 <20110128174105.3235.21014.stgit@matisse.1015granger.net>
	 <1296239682.5464.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29050 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220Ab1A1Sjv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jan 2011 13:39:51 -0500
In-Reply-To: <1296239682.5464.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-01-28 at 13:34 -0500, Trond Myklebust wrote: 
> On Fri, 2011-01-28 at 12:41 -0500, Chuck Lever wrote: 
> > On recent 2.6.38-rc kernels, connectathon basic test 6 fails on
> > NFSv4 mounts of OpenSolaris with something like:
> > 
> > > ./test6: readdir
> > > 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.12' dir entry, pass 0
> > > 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.82' dir entry, pass 0
> > > 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.164' dir entry, pass 0
> > > 	./test6: (/mnt/klimt/matisse.test) Test failed with 3 errors
> > > basic tests failed
> > > Tests failed, leaving /mnt/klimt mounted
> > > [cel@matisse cthon04]$
> > 
> > I narrowed the problem down to nfs4_decode_direct() reporting that the
> > decode buffer had overflowed while decoding the entries for those
> > missing files.
> > 
> > verify_attr_len() assumes both it's pointer arguments reside on the
> > same page.  When these arguments point to locations on two different
> > pages, verify_attr_len() can report false errors.  This can happen now
> > that a large NFSv4 readdir result can span pages.
> > 
> > We have reasonably good checking in nfs4_decode_dirent() anyway, so
> > it should be safe to simply remove the extra checking.
> > 
> > At a guess, this was introduced by commit 6650239a, "NFS: Don't use
> > vm_map_ram() in readdir".
> > 
> > Cc: stable@kernel.org [2.6.37]
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > ---
> > 
> >  fs/nfs/nfs4xdr.c |    3 ---
> >  1 files changed, 0 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> > index 009aef9..4e2c168 100644
> > --- a/fs/nfs/nfs4xdr.c
> > +++ b/fs/nfs/nfs4xdr.c
> > @@ -6132,9 +6132,6 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
> >  	if (entry->fattr->valid & NFS_ATTR_FATTR_TYPE)
> >  		entry->d_type = nfs_umode_to_dtype(entry->fattr->mode);
> >  
> > -	if (verify_attr_len(xdr, p, len) < 0)
> > -		goto out_overflow;
> > -
> >  	return 0;
> >  
> >  out_overflow:
> > 
> 
> I'm assuming that this is 'Cc: stable@kernel.org [2.6.37]'?

Duh... I didn't read the s.o.b.s before replying. Sorry...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

