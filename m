From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: Re: [PATCH] nfs: avoid possible deadlock bug when setting up
	delegation.
Date: Thu, 20 May 2010 21:20:27 +0800
Message-ID: <AANLkTilrfrlhyJ7G8jy6X9emrGIGnEAxFjqlYns8K0OT@mail.gmail.com>
References: <20100520054216.GA27457@vmware>
	 <1274360236.2949.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35021 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712Ab0ETNUa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 May 2010 09:20:30 -0400
Received: by vws9 with SMTP id 9so4670050vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 06:20:29 -0700 (PDT)
In-Reply-To: <1274360236.2949.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 20, 2010 at 8:57 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Thu, 2010-05-20 at 13:42 +0800, Tao Guo wrote:
>> Unlock clp->cl_lock before taking inode->i_lock when setting up
>> delegation to avoid possible deadlock bug.
>
> What deadlock? inode->i_lock should always be the innermost lock, so =
it
> should always be safe to take it while already holding the nfs_client
> lock.
here is: http://marc.info/?l=3Dlinux-nfs&m=3D127424502009958&w=3D2
>
> If somebody is taking the nfs_client lock while holding the inode loc=
k,
> then that would be the deadlock bug that needs to be fixed.
>
mm, I will reconsider that carefully~
> Trond
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>



--=20
tao.
