Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:55923 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbaH2U6T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Aug 2014 16:58:19 -0400
Date: Fri, 29 Aug 2014 21:58:17 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tao Peng <tao.peng@primarydata.com>
Subject: Re: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE
 automounted partitions
Message-ID: <20140829205817.GB7996@ZenIV.linux.org.uk>
References: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 29, 2014 at 12:27:53PM -0400, Trond Myklebust wrote:
> Hi Al,
> 
> Our internal testing shows that commit aba809cf0944 (namespace.c: get
> rid of mnt_ghosts) appears to break the NFS automounter functionality.
> When unmounting, the user now gets a permanent -EBUSY, presumably due
> to a refcounting issue with the patch.
> 
> The reproducer is as follows:
> 
> On the server, set up an export of the form:
> 
> % showmount -e 192.168.214.128
> Export list for 192.168.214.128:
> /export *
> 
> On the client:
> 
> [fedora19@~]$sudo mount 192.168.214.128:/ /mnt/
> [fedora19@~]$df
> Filesystem               Size  Used Avail Use% Mounted on
> /dev/mapper/fedora-root   38G   15G   24G  38% /
> devtmpfs                 229M     0  229M   0% /dev
> tmpfs                    242M   80K  242M   1% /dev/shm
> tmpfs                    242M  1.5M  241M   1% /run
> tmpfs                    242M     0  242M   0% /sys/fs/cgroup
> tmpfs                    242M  4.0K  242M   1% /tmp
> /dev/sda1                1.5G  248M  1.3G  17% /boot
> 192.168.214.128:/         28G   25G  1.1G  96% /mnt
> [fedora19@~]$ls /mnt/export/
> [fedora19@~]$df
> Filesystem               Size  Used Avail Use% Mounted on
> /dev/mapper/fedora-root   38G   15G   24G  38% /
> devtmpfs                 229M     0  229M   0% /dev
> tmpfs                    242M   80K  242M   1% /dev/shm
> tmpfs                    242M  1.5M  241M   1% /run
> tmpfs                    242M     0  242M   0% /sys/fs/cgroup
> tmpfs                    242M  4.0K  242M   1% /tmp
> /dev/sda1                1.5G  248M  1.3G  17% /boot
> 192.168.214.128:/         28G   25G  1.1G  96% /mnt
> 192.168.214.128:/export   28G   25G  1.1G  96% /mnt/export
> [fedora19@~]$sudo umount /mnt
> umount.nfs4: /mnt: device is busy
> [fedora19@~]$df
> Filesystem               Size  Used Avail Use% Mounted on
> /dev/mapper/fedora-root   38G   15G   24G  38% /
> devtmpfs                 229M     0  229M   0% /dev
> tmpfs                    242M   80K  242M   1% /dev/shm
> tmpfs                    242M  1.5M  241M   1% /run
> tmpfs                    242M     0  242M   0% /sys/fs/cgroup
> tmpfs                    242M  4.0K  242M   1% /tmp
> /dev/sda1                1.5G  248M  1.3G  17% /boot
> 192.168.214.128:/         28G   25G  1.1G  96% /mnt
> 
> Reverting commit aba809cf0944 fixes the problem for us on a 3.14.15
> client kernel.

Can't reproduce on a debian client with 3.12 kernel (which contains the
commit in question); it'll take a bit to get Fedora setup - I have it as KVM
image, but it's sandboxed to hell and back and certainly not allowed to play
with NFS traffic...

In the meanwhile, if you have a reproducer setup...  Could you verify that
fuser -m /mnt does come empty?  Another thing: does mount --make-rprivate /
done before that umount /mnt change behaviour?  IOW, I wonder if it could
be affected by shared-subtree setup; that might be the relevant difference
between the working box and F19 one in this case.  Could you at least post
the contents of /proc/*/mountinfo from all namespaces?  Output of
grep . `md5sum /proc/*/mountinfo|sort|uniq -w32|awk '{print $2}'`
would do...
