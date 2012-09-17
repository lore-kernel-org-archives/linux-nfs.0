Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12801 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206Ab2IQMvg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2012 08:51:36 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: What is NFSv4 READDIR doesn't return a filehandle....
Date: Mon, 17 Sep 2012 12:51:33 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FC54E3@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120917090537.20e38026@notabene.brown>
In-Reply-To: <20120917090537.20e38026@notabene.brown>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of NeilBrown
> Sent: Sunday, September 16, 2012 7:06 PM
> To: linux-nfs@vger.kernel.org
> Subject: What is NFSv4 READDIR doesn't return a filehandle....
> 
> 
> In NFSv4, the server can report which attributes it chose to return in a
> READDIR reply.
> 
> A customer has come across a server which does not return the filehandle
> information (is that allowed?).

The filehandle attribute is a mandatory attribute according to RFC3530, so I believe that the answer is "no".

> A consequence of this is that Linux/NFS gets confused.
> nfs_readdir_page_filler calls nfs_prime_dcache() (because it was a readdir
> plus request that was sent) and nfs_prime_dcache goes ahead and creates
> an inode based on the filehandle that it has.
> However decode_attr_filehandle() had happily decoded nothing as the
> FATTR4_WORD0_FILEHANDLE bit wasn't set.
> So the inode gets created with a zero-length filehandle and when this gets
> sent back to the server to act on the inode, it gets NFS4ERR_BADHANDLE to
> the PUTFH op.
> 
> So should nfs_prime_dcache() abort if the filehandle doesn't exist (patch
> below) or should nfs_fhget() return an error if the filehandle is empty?
> 
> Or maybe this behaviour should be detected and readdir should be disabled
> for that server?
> 

I don't want to have to code the client to deal with broken servers. If we start down that path, then we'll end up doing nothing else.

I can, however, see a case for extending the "nordirplus" mount option to cover NFSv4. Currently it only acts on NFSv3 mounts...

Cheers
  Trond
