Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35063 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbcFTGfL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 02:35:11 -0400
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
To: leon@kernel.org, Chuck Lever <chuck.lever@oracle.com>
References: <20160616143518.GX5408@leon.nu> <576315C9.30002@gmail.com>
 <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
 <20160617092018.GZ5408@leon.nu>
 <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
 <20160618105650.GD5408@leon.nu>
 <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
 <57666E14.2070802@gmail.com>
 <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
 <B62EEE84-454D-4D55-9C7E-653F564DF381@oracle.com>
 <20160620054453.GA1172@leon.nu>
Cc: Or Gerlitz <gerlitz.or@gmail.com>, Yishai Hadas <yishaih@mellanox.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <57678E74.1070308@grimberg.me>
Date: Mon, 20 Jun 2016 09:34:28 +0300
MIME-Version: 1.0
In-Reply-To: <20160620054453.GA1172@leon.nu>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Yishai and me follow this thread closely and we work on finding the
> root cause of this issue.

Thanks Leon and Yishai, let me know if you need any help with this.

Do you agree we should move forward with the original patch until
we get this resolved?

Also, did anyone find out if this is happening in mlx5 as well?
(Chuck?), if not then this would trim the root-cause to be a mlx4
specific issue.
