Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38863 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058Ab1HJTfR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Aug 2011 15:35:17 -0400
Date: Wed, 10 Aug 2011 15:35:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org, hch@infradead.org,
        yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org, tytso@mit.edu,
        adilger@whamcloud.com
Subject: Re: [PATCH 4/4] nfsd: vfs_llseek() with 32 or 64 bit offsets
 (hashes)
Message-ID: <20110810193511.GB27784@fieldses.org>
References: <20110808153432.1872437.85783.stgit@fsdevel3>
 <20110808153813.1872437.44997.stgit@fsdevel3>
 <20110809173342.GB16206@fieldses.org>
 <4E42D845.7060905@itwm.fraunhofer.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E42D845.7060905@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 10, 2011 at 09:13:09PM +0200, Bernd Schubert wrote:
> On 08/09/2011 07:33 PM, J. Bruce Fields wrote:
> >On Mon, Aug 08, 2011 at 05:38:13PM +0200, Bernd Schubert wrote:
> >>Use 32-bit or 64-bit llseek() hashes for directory offsets depending on
> >>the NFS version. NFSv2 gets 32-bit hashes only.
> >>
> >>NOTE: This patch got rather complex as Christoph asked to set the
> >>filp->f_mode flag in the open call or immediatly after dentry_open()
> >>in nfsd_open() to avoid races.
> >>Personally I still do not see a reason for that and in my opinion
> >>FMODE_32BITHASH/FMODE_64BITHASH flags could be set nfsd_readdir(), as it
> >>follows directly after nfsd_open() without a chance of races.
> >
> >The bulk of the patch seems to be just an access->may_flags rename.
> >Could you please split that into a separate patch?
> 
> Ok, shall I resend the entire patch series, but already remove the
> 32-bit nfsd_readdir() cookie patch? Or only just this patch split
> into to parts?

Probably best to resend.  Who's going to take these patches?

(Looked like it would probably make the most sense for an ext4 tree, as
that looked like the trickiest part?  But I'll take the nfsd4 fix.)

--b.
