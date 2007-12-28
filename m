From: Martin Knoblauch <spamtrap@knobisoft.de>
Subject: Strange NFS write performance Linux->Solaris-10/VXFS, maybe VW related
Date: Fri, 28 Dec 2007 07:24:59 -0800 (PST)
Message-ID: <713696.79839.qm@web32608.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755202AbXL1PZS@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

 currently I am tracking down an "interesting" effect when writing to a Solars-10/Sparc based server. The server exports two filesystems. One UFS, one VXFS. The filesystems are mounted NFS3/TCP, no special options. Linux kernel in question is 2.6.24-rc6, but it happens with earlier kernels (2.6.19.2, 2.6.22.6) as well. The client is x86_64 with 8 GB of ram. 

 The problem: when writing to the VXFS based filesystem, performance drops dramatically when the the filesize reaches or exceeds "dirty_ratio". For a dirty_ratio of 10% (about 800MB) files below 750 MB are transfered with about 30 MB/sec. Anything above 770 MB drops down to below 10 MB/sec. If I perform the same tests on the UFS based FS, performance stays at about 30 MB/sec until 3GB and likely larger (I just stopped at 3 GB).

 Any ideas what could cause this difference? Any suggestions on debugging it?

spsdm5:/lfs/test_ufs on /mnt/test_ufs type nfs (rw,proto=tcp,nfsvers=3,hard,intr,addr=160.50.118.37)
spsdm5:/lfs/test_vxfs on /mnt/test_vxfs type nfs (rw,proto=tcp,nfsvers=3,hard,intr,addr=160.50.118.37)

Cheers
Martin
PS: Please CC me, as I am not subscribed. Don't worry about the spamtrap name :-)

------------------------------------------------------
Martin Knoblauch
email: k n o b i AT knobisoft DOT de
www:   http://www.knobisoft.de


