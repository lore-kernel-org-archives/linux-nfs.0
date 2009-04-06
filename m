From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: next-20090406: nfsd build fails
Date: Mon, 06 Apr 2009 11:53:28 +0300
Message-ID: <49D9C308.6020500@panasas.com>
References: <a4423d670904060027y44550d99g2cb40ce415dbb048@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	linux-nfs@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Alexander Beregalov <a.beregalov@gmail.com>, andros@netapp.com,
	bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:6965 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753623AbZDFIxm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2009 04:53:42 -0400
In-Reply-To: <a4423d670904060027y44550d99g2cb40ce415dbb048-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 06, 2009, 10:27 +0300, Alexander Beregalov <a.beregalov@gmail.com> wrote:
> Hi
> 
> fs/nfsd/nfssvc.c: In function 'set_max_drc':
> fs/nfsd/nfssvc.c:240: error: 'NFSD_DRC_SIZE_SHIFT' undeclared
> 
> CONFIG_NFSD_V4 is not set

Hi Alexander,

Thanks for reporting this!

Andy, Bruce: please see attached 2 patches fixing compile/link errors
with DRC under !defined(CONFIG_NFSD_V4):

[PATCH 1/2] SQUASHEM: nfsd41: define NFSD_DRC_SIZE_SHIFT in set_max_drc
[PATCH 2/2] SQUASHME: nfsd41: define nfsd4_set_statp as noop for !CONFIG_NFSD_V4

Benny
