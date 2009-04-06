From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: next-20090406: nfsd build fails
Date: Mon, 6 Apr 2009 13:11:46 -0400
Message-ID: <20090406171146.GA32436@fieldses.org>
References: <a4423d670904060027y44550d99g2cb40ce415dbb048@mail.gmail.com> <49D9C308.6020500@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Beregalov <a.beregalov@gmail.com>, andros@netapp.com,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	linux-nfs@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:33493 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757357AbZDFRL4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2009 13:11:56 -0400
In-Reply-To: <49D9C308.6020500@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 06, 2009 at 11:53:28AM +0300, Benny Halevy wrote:
> On Apr. 06, 2009, 10:27 +0300, Alexander Beregalov <a.beregalov@gmail.com> wrote:
> > Hi
> > 
> > fs/nfsd/nfssvc.c: In function 'set_max_drc':
> > fs/nfsd/nfssvc.c:240: error: 'NFSD_DRC_SIZE_SHIFT' undeclared
> > 
> > CONFIG_NFSD_V4 is not set
> 
> Hi Alexander,
> 
> Thanks for reporting this!
> 
> Andy, Bruce: please see attached 2 patches fixing compile/link errors
> with DRC under !defined(CONFIG_NFSD_V4):
> 
> [PATCH 1/2] SQUASHEM: nfsd41: define NFSD_DRC_SIZE_SHIFT in set_max_drc
> [PATCH 2/2] SQUASHME: nfsd41: define nfsd4_set_statp as noop for !CONFIG_NFSD_V4

Thanks, applied.

Committing on top (not squashing) since I'd rather not rewrite history
on a branch I've already sent a pull request for.

(In fact, I'll try to stop rebasing those for-next branches at all this
time around.)

--b.
