Received: from mail-wr2-f12.google.com (mail-wr2-f12.google.com [74.125.225.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73A873EC691
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 06:59:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.225.76
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789541997; cv=pass; b=prK2PArDx7MaGso5Bs0XZMgkXUhPxWcY1s2G6s9YFgs25QDUwAg9VDgJ7i+WJqTEWAMxc9+H06JF5oLzzF0s8UfWrYoa8wIUKbF0nDtlXZYRbmpUaRsfnVxP3iwA8rkprLYHZsvhncEtPUZra6XKVrLcJZJV0g0gxSXjHNMhFyo=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789541997; c=relaxed/simple;
	bh=NsFK5lBLdksgQCKOANm3YAnPr1p7FDQOhLcuqTO5IpM=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Cc:Content-Type; b=h5Qtzb0ubhu1Y+wkMfrwtGk95UceB7SFop3OABgXOj0yuuyWAOi6bacqe1TkwqrwR63qSM6RTGrT6g8dVQYYoqCD+ru/vD9pngGh96zn8tn6OLjZPEKgdExSZgFSjqjLR1o1qGdNIcMcMs+TeXn3fzS0CuA41ACa366WCEkRM8A=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=aEd8hPGR; arc=pass smtp.client-ip=74.125.225.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="aEd8hPGR"
Received: by mail-wr2-f12.google.com with SMTP id ffacd0b85a97d-4843378fb37so177745f8f.3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 23:59:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789541993; cv=none;
        d=google.com; s=arc-20260327;
        b=MIdcKdAAD7ywNCNTWh3H5Go/Z3e8NKJLjWbsRrfPeHQx5UylfVXFmHiHQ/ziq2ZVFD
         R6x5fi2EHJtDxR3CplkV1ELu09D+LocMl5jYXzqxz/fmNIYuqAiWRIcCVYw/LW7xAInT
         LddrSLNpR8Id4tvzOIel79KaynXqVtLj0Wv4z0jJXjVFe1a47OJd8VUIFs6cACNX8VIp
         vg37lJe9ysCloDSo7PLPGcMCZR54tPNiywzswq2JMlYLPYhGblrV+Xjjja9e6z8/hltJ
         o6y45x916rQVyun1NKzkOz6t/dhjY8x+xOoTs/VS8b1yQ31iAEw/2m0DS2UHHAGfEckd
         gnvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :mime-version:dkim-signature;
        bh=OxRv6yCuRqsbWvAT6YBIWbqNgEcNj7stzbBHK5z0Hkk=;
        fh=bGKTSn4It4PPs31bfZ6OTq3WgTKSkO5YiE6V7iJEh4k=;
        b=cGQbeMGPffa6qo9loQxNCXHKFiioecG1fUDHI8v5YxGkspx4WvsWBeHD6VVW1dH0Rl
         W80tpoW/fj0MqoNBNaJnhbU9x9s3bSysEuicza+BNxdgBIAfqceTFw6h9MwMhwzNUdvY
         +E72CqpYUUORuap6nVjJBsrTAxpe4S3l1HEDxWT9kp9Vgi/8cw/gea8cM149GUAwrWFc
         1+9uXDtMwn+m4r9xDGUoVdYqWbWOAbXOyE5k9yHSKF6WYWi0yVlvm2BvALuRt5T4+3Ol
         53aQ6kDfxuKSlACg1SQ9urxEv9zKAhFYoJ8JLArCPoepfCosOs1wzJFlmuVYjiTin4v1
         0W7w==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1789541993; x=1790146793; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=OxRv6yCuRqsbWvAT6YBIWbqNgEcNj7stzbBHK5z0Hkk=;
        b=aEd8hPGRsxfwb/UoqnOHSIsx7PExyKgdefiKh/GOG2kI7m6h6Aaqm+iW9BADjArYU/
         XwcLGmzZobL/+CpuRHD52j6ITbfILxdZEv+Vpo/k9Vs4uMy6MvP2DRNaRAsDpb3gAD9a
         JSyRvuVWeNN5/C2hxRgPgeB3xtAZsQvAUx51lHmss2rnpZmVHld4gel04EWTVaM6GtvQ
         WF/c/Y6XraKaYk9OO/FPwBEMH7/lwMhlm9WmxvwwGWJRmFieS1GQDsIJgtD9IoSZHjrN
         nAWks2CdETF03gXG55b9ErI564LvbQfuSuq3BAPzar12t0cJxTs0snPZPdwXKOr3E89U
         hAhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789541993; x=1790146793;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=OxRv6yCuRqsbWvAT6YBIWbqNgEcNj7stzbBHK5z0Hkk=;
        b=WSPCZNe7e5KPcC+b4+sJGyIsM6f5M10G6PSYFRWcQ6JSFE85aSg1cC8eerqEQU+/P7
         Y8X4tVxLlt/rcUkYeYfmW15SGczFnmLZ2waKXMdd+0RCeDjhXrMHxL7rzDIrqFqVgtx4
         dm0Kqsfll10/o3GHjW2Z3/IXG/O39NElWKd8FZnfLjwBVHZXofw+UmDTPW4WL+D2Za5A
         28rrN+smzKM6gOdXqOeng7QCBhiW0DhTbbs74hQiytxvChtAVk8VK4yGgssuwN3DCDmt
         v5zCD8bwdV1PQxzDoQ96rv8EPUcggcun97+JBrZ4ud6HU2aZCdJrfgTC2l5II98trwKb
         30OA==
X-Gm-Message-State: AFuF++nANdqICVDXa5NOEX+jw7z+OTAbWf+2gQRmk3OjcUsogdBNmVNj
	p8eIrb3h10IvpxMVUuX9GppQIIczQHmodbzOA2ZeD9DzzMDaA9MlY0JzHbRHrA+scAqx3p9VgGM
	YIyc9wuSpd1sgsH7CidPiDDhEcRQZCvd2PyEJclKoa+scH164zk/1LnXbNA==
X-Gm-Gg: AYBFou0PXcTz2ajzvCQGQy0fA8/r9GhaF9yw1uvVUgoiMFFv5kOOQ3nxmxqjV6dzHKa
	2pbs13ZFiQpoK3KHwNbfvF08wesupQ1XoefZMTJRwQxeK4TKDuwXYaPi1C12ulg6kshPh6lkxnD
	OFGM6htJYw6T0VSr5nLt/aRJNIBZ6ie5gv5knTUFlPjPNIA2N2GrOm2im5SPZ4EELCJ4xjyz8iP
	OzjkUEGZYgSxuN0dY448R8M0oI/6zH+6RqrTZmN2pTLGHrbWhsD5ROZ1AaxO0t33PKs/67WO7a6
	70cHHxcgJ8FjQZRu/qnfNE3L8gRh0EXLgm0F5EhWVlOuYUylaemz5fDz
X-Received: by 2002:a05:6000:41e6:b0:487:981:4e0d with SMTP id
 ffacd0b85a97d-4870cef12ffmr1598765f8f.19.1789541993327; Tue, 15 Sep 2026
 23:59:53 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: "Sirisha Mylavarapu (she/her)" <smylavarapu@everpuredata.com>
Date: Wed, 16 Sep 2026 12:29:41 +0530
X-Gm-Features: AcwNN1UbbJK3z4QtoObtS3Rrx-3WNhrwiaUkg_WlUPpZaDMMuDQXcRWCi8Y5iUI
Message-ID: <CABc6Dy5mvvCSECx2z+-L1q6FpQGO_hQfoLaS6vtpWVud6+8zbA@mail.gmail.com>
Subject: cgroup v2 io.max throttling works for NFSd reads but not writes
To: linux-nfs@vger.kernel.org
Cc: cgroups@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

I have been experimenting with cgroup v2 io.max throttling for NFSd on
kernel 7.0.0-14-generic (Ubuntu 26.04) and I wanted to share results
and ask for recommendations.

Goal: Throttle NFS server I/O bandwidth using cgroup v2 io.max by
placing nfsd kernel threads in a dedicated cgroup, to limit block
device I/O performed by the NFS server.

Setup:

-NFSd direct I/O mode enabled via debugfs (io_cache_read=3D2, io_cache_writ=
e=3D2).
-All 16 [nfsd] kernel threads moved to a dedicated cgroup
(system.slice/nfsd.slice)
-io.max throttle set to 50 MB/s on underlying block device (sdb,64GB
disk, major:minor 8:16).
-NFS export mounted locally via loopback for testing.
-fio used for benchmarks


Results:
Read throttling works as expected, consistently capped at 50 MB/s.
Write throttling doesn't work regardless of io_cache_write mode(tried
DIRECT=3D2 and DONTCACHE=3D1).

Root cause (as I understand it): The NFS client buffers writes in the
local page cache and returns immediately to the application. The
actual disk write happens asynchronously, so the application never
waits for data to reach disk =E2=80=94 meaning the throttle does not provid=
e
backpressure to the writer even when the nfsd cgroup's io.max is
active.

Questions:
1. Is NFSd write throttling via cgroup v2 io.max a known limitation?
Is there active upstream work to address this?
2. Are there any known workarounds or recommended approaches to
achieve NFS write I/O throttling at the server side?

Any pointers to upstream patches or LKML threads would be appreciated.

Experiment:
1. Load nfsd module

root@smylavarapu-16-0:~# modprobe nfsd
root@smylavarapu-16-0:~# ls /sys/kernel/debug/nfsd
disable-splice-read  io_cache_read  io_cache_write

2. Enable Direct I/O mode

root@smylavarapu-16-0:~# echo 2 > /sys/kernel/debug/nfsd/io_cache_read
root@smylavarapu-16-0:~# echo 2 > /sys/kernel/debug/nfsd/io_cache_write
root@smylavarapu-16-0:~# cat /sys/kernel/debug/nfsd/io_cache_read
2

3. Start NFS server and verify nfsd kernel threads

root@smylavarapu-16-0:~# systemctl start nfs-server
root@smylavarapu-16-0:~# ps aux | grep '\[nfsd\]'
root  662609  0.0  0.0  0  0 ?  I  10:48  0:00 [nfsd]
root  662610  0.0  0.0  0  0 ?  I  10:48  0:00 [nfsd]
... (16 threads total, PIDs 662609=E2=80=93662624)
root@smylavarapu-16-0:~# cat /proc/$(pgrep -x nfsd | head -1)/cgroup
0::/

4. Format and mount real block device (sdb)

root@smylavarapu-16-0:~# mkfs.ext4 /dev/sdb
mke2fs 1.47.2 (1-Jan-2025)
Discarding device blocks: done
Creating filesystem with 16777216 4k blocks and 4194304 inodes
...done
root@smylavarapu-16-0:~# mount /dev/sdb /nfs-test-export
root@smylavarapu-16-0:~# ls -la /dev/sdb
brw-rw---- 1 root disk 8, 16 Sep 15 14:02 /dev/sdb
major:minor =3D 8:16

5. Export over NFS and mount locally

root@smylavarapu-16-0:~# echo "/nfs-test-export
*(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
root@smylavarapu-16-0:~# exportfs -ra
root@smylavarapu-16-0:~# exportfs -v
/nfs-test-export
<world>(sync,wdelay,hide,no_subtree_check,sec=3Dsys,rw,secure,no_root_squas=
h,no_all_squash)
root@smylavarapu-16-0:~# mkdir -p /mnt/nfs-client
root@smylavarapu-16-0:~# mount -t nfs 127.0.0.1:/nfs-test-export /mnt/nfs-c=
lient
root@smylavarapu-16-0:~# df -h /mnt/nfs-client
Filesystem                  Size  Used Avail Use% Mounted on
127.0.0.1:/nfs-test-export   63G  2.0M   60G   1% /mnt/nfs-client

6. Move nfsd threads to dedicated cgroup

root@smylavarapu-16-0:~# mkdir -p /sys/fs/cgroup/system.slice/nfsd.slice
root@smylavarapu-16-0:~# cat /sys/fs/cgroup/system.slice/cgroup.subtree_con=
trol
cpuset cpu io memory hugetlb pids rdma misc dmem
root@smylavarapu-16-0:~# echo "+io" >
/sys/fs/cgroup/system.slice/cgroup.subtree_control
root@smylavarapu-16-0:~# for pid in $(pgrep -x nfsd); do
    echo $pid > /sys/fs/cgroup/system.slice/nfsd.slice/cgroup.procs
done
root@smylavarapu-16-0:~# cat /proc/$(pgrep -x nfsd | head -1)/cgroup
0::/system.slice/nfsd.slice

7. Apply 50 MB/s throttle

root@smylavarapu-16-0:~# echo "8:16 wbps=3D52428800 rbps=3D52428800" >
/sys/fs/cgroup/system.slice/nfsd.slice/io.max
root@smylavarapu-16-0:~# cat /sys/fs/cgroup/system.slice/nfsd.slice/io.max
8:16 rbps=3D52428800 wbps=3D52428800 riops=3Dmax wiops=3Dmax

8. Write test =E2=80=94 io_cache_write=3D2

root@smylavarapu-16-0:~# fio --name=3Dnfs-write --rw=3Dwrite --bs=3D1M --si=
ze=3D4G \
    --filename=3D/mnt/nfs-client/testfile --group_reporting --runtime=3D30
--time_based
WRITE: bw=3D1761MiB/s (1847MB/s), io=3D52.0GiB, run=3D30236msec
=E2=86=92 NOT throttled (1761 MB/s)

9. Write test after drop_caches =E2=80=94 io_cache_write=3D2

root@smylavarapu-16-0:~# echo 3 > /proc/sys/vm/drop_caches
root@smylavarapu-16-0:~# fio --name=3Dnfs-write --rw=3Dwrite --bs=3D1M --si=
ze=3D4G \
    --filename=3D/mnt/nfs-client/testfile --group_reporting --runtime=3D30
--time_based
WRITE: bw=3D2315MiB/s (2427MB/s), io=3D68.1GiB, run=3D30127msec
=E2=86=92 NOT throttled (2315 MB/s)

10. Read test =E2=80=94 io_cache_read=3D2

root@smylavarapu-16-0:~# echo 3 > /proc/sys/vm/drop_caches
root@smylavarapu-16-0:~# fio --name=3Dnfs-read --rw=3Dread --bs=3D1M --size=
=3D4G \
    --filename=3D/mnt/nfs-client/testfile --group_reporting --runtime=3D30
--time_based

READ: bw=3D50.0MiB/s (52.4MB/s), IOPS=3D49, io=3D1501MiB, run=3D30032msec
=E2=86=92 THROTTLED (capped at 50 MB/s)

Thank you,
Sirisha.
