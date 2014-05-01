Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx6-phx2.redhat.com ([209.132.183.39]:33070 "EHLO
	mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbaEAQEN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 12:04:13 -0400
Date: Thu, 1 May 2014 12:03:41 -0400 (EDT)
From: Doug Ledford <dledford@redhat.com>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: yanb <yanb@mellanox.com>, Phil Cayton <phil.cayton@intel.com>,
        Susan K Coulter <skc@lanl.gov>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Devesh.Sharma" <Devesh.Sharma@emulex.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Allen Andrews <Allen.Andrews@emulex.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Or Gerlitz <or.gerlitz@gmail.com>,
        Chuck Lever <chuck.lever@oracle.com>
Message-ID: <8741333.1801.1398960224265.JavaMail."Doug Ledford"@Phenom>
In-Reply-To: <5361D89F.4070503@oracle.com>
References: <53614C03.80606@oracle.com> <CAJZOPZJioYdcbDGsk7278sZS7kD9W1dcGEGtYfsFk=Mm7DW3fQ@mail.gmail.com> <BBF761A6-2407-4457-92D5-8C2EC736BC9D@oracle.com> <CAJZOPZJgp-QdxR+PmwACWOSc4h_167J0iBjfmMrPX8sek600WA@mail.gmail.com> <536161D0.3000600@oracle.com> <"30686627.1636.1398902288314.JavaMail.Doug Ledford"@Phenom> <5361D89F.4070503@oracle.com>
Subject: Re: NFSoRDMA developers bi-weekly meeting announcement (4/30)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/01/2014, Shirley Ma wrote: 
> On 04/30/2014 04:58 PM, Doug Ledford wrote:
> > On 04/302014 Shirley Ma wrote:
> >> I've created Xen guest on DomU. Dom0 PF works which has no mtts
> >> been
> >> enabled, however DomU I hit this problem by just mounting the file
> >> system:
> >> mlx4_core 0000:00:04.0: Failed to allocate mtts for 66 pages(order
> >> 7)
> >> mlx4_core 0000:00:04.0: Failed to allocate mtts for 4096
> >> pages(order
> >> 12)
> >> mlx4_core 0000:00:04.0: Failed to allocate mtts for 4096
> >> pages(order
> >> 12)
> >>
> >> RDMA microbenchmark perftest works ok. I enabled mtts scripts when
> >> booting the Xen guest. cat /proc/mtrr:
> > What OS/RDMA stack are you using?  I'm not familiar with any mtts
> > scripts, however I know there is an mtrr fixup script I wrote for
> > the RDMA stack in Fedora/RHEL (and so I assume it's in Oracle Linux
> > too, but I haven't checked).  In fact, I assume that's the script
> > you are referring to based on the fact that your next bit of your
> > email cats the /proc/mtrr file.  But I don't believe whether there
> > is an mtrr setting mixup or not that is should have any impact on
> > the mtts allocations in the driver.  Even if your mtrr registers
> > were set incorrectly, the problem then becomes either A) a serious
> > performance bottleneck (in the case of Intel hardware that needs
> > write combining in order to get more than about 50MByte/s of
> > throughput on their cards) or B) failed operation because MMIO
> > writes to the card are being cached/write combined when they should
> > not be.
> >
> > I suspect this is more likely Xen related than mtts/mtrr related.
> Yes. That's the script I used. I wonder whether it's possible to
> disable
> mtrr on DomU guest to debug this. I am new to Xen.

No, it's not possible to disable mtrr and expect any pass through
PCI devices to work.  The mtrr registers merely indicate what
portion of the memory map should be treated as normal memory (meaning
cacheable) and what should be treated as MMIO memory (meaning generally
non-cacheable).  That's all they do.  The mtts table allocation
failures are actually totally different.  In the VF on DomU they
are passed to the PF on Dom0 and the command is done there.  However,
the number of mtts available for the slave are limited (check the
code in resource_tracker.c).  In addition, the number of mtts
allocated is proportionally related to memory size in the guest
and inversely related to the log2_mtts_per_seg (probably both on
Dom0 and DomU, which I suspect need to agree on the log2_mtts_per_seg
module parameter).  I would try a combination of reducing the memory
in the quest, or increasing the log2_mtts_per_seg, or both, and
see if you can get it to work.

-- 
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD
	      http://people.redhat.com/dledford

