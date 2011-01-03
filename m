Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63756 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390Ab1ACQew (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jan 2011 11:34:52 -0500
Date: Mon, 3 Jan 2011 19:34:36 +0300
From: Dan Carpenter <error27@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch -next] lockd: double unlock in next_host_state()
Message-ID: <20110103163403.GY1886@bicker>
References: <20110102202042.GN1886@bicker>
 <001458D4-F513-4959-9BE7-476F8542D009@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <001458D4-F513-4959-9BE7-476F8542D009@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 03, 2011 at 10:59:36AM -0500, Chuck Lever wrote:
> > -			mutex_unlock(&nlm_host_mutex);
> > 			goto out;
> > 		}
> > 	}
> 
> Would it also make sense to replace the "goto out;" with a "break;" ?

No.  for_each_host() is a nested for loop, so a break would only take
you out of the inner most loop.

regards,
dan carpenter

