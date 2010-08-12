Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54397 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab0HLSue (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Aug 2010 14:50:34 -0400
Received: by eya25 with SMTP id 25so879602eya.19
        for <linux-nfs@vger.kernel.org>; Thu, 12 Aug 2010 11:50:33 -0700 (PDT)
In-Reply-To: <1281634004.14329.14.camel@heimdal.trondhjem.org>
References: <87lj8ckb1e.fsf@patl.com>
	<8762zgmmer.fsf@patl.com>
	<1281628195.2873.12.camel@heimdal.trondhjem.org>
	<AANLkTi=WzNzq7wKf0qa+VFuOBYy4yW==0QvdKsTQ88+x@mail.gmail.com>
	<1281634004.14329.14.camel@heimdal.trondhjem.org>
Date: Thu, 12 Aug 2010 11:50:27 -0700
Message-ID: <AANLkTikStDSBi2Dm0oMAEpVbE9PFZOTmOkW6Wy92wjj-@mail.gmail.com>
Subject: Re: [PATCH] nfs: lookupcache coherence bugs in WCC update path (revised)
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 12, 2010 at 10:26 AM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
>
> My hunch is that you are seeing a server bug rather than a client bug
> here...

I believe I am close to finding the actual bug, but there is some code
in the NFS server that is confusing me.

Here is linux-2.6.35/fs/nfsd/vfs.c, lines 212-227 (in function
nfsd_lookup_dentry):

        } else {
                fh_lock(fhp);
                dentry = lookup_one_len(name, dparent, len);
                host_err = PTR_ERR(dentry);
                if (IS_ERR(dentry))
                        goto out_nfserr;
                /*
                 * check if we have crossed a mount point ...
                 */
                if (nfsd_mountpoint(dentry, exp)) {
                        if ((host_err = nfsd_cross_mnt(rqstp, &dentry, &exp))) {
                                dput(dentry);
                                goto out_nfserr;
                        }
                }
        }


Shouldn't there be a call to "fh_unlock()" to match the call to
"fh_lock()"?  Can anyone tell me where the corresponding fh_unlock()
call appears, or if it does not appear, why it is not needed?

Thanks...

 - Pat
