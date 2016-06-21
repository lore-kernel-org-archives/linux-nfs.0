Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:34078 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbcFUOfR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 10:35:17 -0400
Date: Tue, 21 Jun 2016 10:35:06 -0400 (EDT)
From: Laurence Oberman <loberman@redhat.com>
To: Sagi Grimberg <sagigrim@gmail.com>
Cc: Yishai Hadas <yishaih@dev.mellanox.co.il>,
        Chuck Lever <chuck.lever@oracle.com>, leon@kernel.org,
        Or Gerlitz <gerlitz.or@gmail.com>, Yishai Hadas <yishaih@mellanox.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Majd Dibbiny <majd@mellanox.com>
Message-ID: <264684354.344357.1466519706695.JavaMail.zimbra@redhat.com>
In-Reply-To: <5769479C.8070605@gmail.com>
References: <20160616143518.GX5408@leon.nu> <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com> <57666E14.2070802@gmail.com> <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com> <B62EEE84-454D-4D55-9C7E-653F564DF381@oracle.com> <20160620054453.GA1172@leon.nu> <12ee28bb-b838-ed4c-5f84-0cb8f1760d63@dev.mellanox.co.il> <5769479C.8070605@gmail.com>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Sagi Grimberg" <sagigrim@gmail.com>
> To: "Yishai Hadas" <yishaih@dev.mellanox.co.il>, "Chuck Lever" <chuck.lever@oracle.com>
> Cc: leon@kernel.org, "Or Gerlitz" <gerlitz.or@gmail.com>, "Yishai Hadas" <yishaih@mellanox.com>, "linux-rdma"
> <linux-rdma@vger.kernel.org>, "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>, "Majd Dibbiny"
> <majd@mellanox.com>
> Sent: Tuesday, June 21, 2016 9:56:44 AM
> Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
> 
> 
> > Just found the root cause of the problem, it was found to be a hardware
> > limitation that is described as part of the PRM. The driver code had to
> > be written accordingly, confirmed that internally with the relevant people.
> >
> >  From PRM:
> > "The PBL should be physically contiguous, must reside in a
> > 64-byte-aligned address, and must not include the last 8 bytes of a page."
> >
> > The last sentence pointed that only one page can be used as the last 8
> > bytes should not be included. That's why there is a hard limit in the
> > code for 511 entries.
> >
> > Re the candidate fix that you sent, from initial review it makes sense,
> > we'll formally confirm it soon after finalizing the regression testing
> > in our side.
> >
> > Thanks Chuck and Sagi for evaluating and working on a solution.
> 
> Thanks Yishai,
> 
> That clears up the root-cause.
> 
> Does the same holds for mlx5? or we can leave it alone?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Also wondering about mlx5 because the default is coherent and increasing the allowed queue depth got me into the swiotlb error situation.
Backing the queue depth down per Bart's suggestion to 32 avoids the swiotlb errors.
Likley 128 is too high anyway, but the weird part of my testing as already mentioned was that its only seen during reconnect activity.

Thanks
Laurence
