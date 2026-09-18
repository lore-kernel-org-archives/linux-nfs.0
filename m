Received: from mail-wm2-f13.google.com (mail-wm2-f13.google.com [74.125.225.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9EE933C1F22
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 03:18:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.225.141
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789701511; cv=pass; b=RvFc89X1EXyxKqzKCG6qUrw28RWPHQeGzmO/U2KLVfDqnvY/Mm5BKzM9rCAABmbclja9jR/rO5YvkNO4XobbCe10DMZFwAGc2bDcKUU6tIaCcyqaPWLwA/8YCHC5kfDH77je2GgCID5ffzqGNin3Jeo4WeYjXwRnp+N/AjKP2sY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789701511; c=relaxed/simple;
	bh=nPzxDn8dM3cyVLdxRT41WQUQ4PHmVQsnKSrOXOor0J0=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=tOp/4CBu/gK+kptpRjWxYRIh5KqCNGnCpciN5mc6kMRtXAJQZgmyjwY1DaoSmmGMHxPqhZ/kO9Hf3hauNoJ564VHdXPbSSnvSkCdVkv+HWGZkbeZ3OKCmo464GKZ0rTysajgGADWnVSGrDcX7rsjnrChluuT8WVgU4Bx/CjiEF8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=W/gmp0eW; arc=pass smtp.client-ip=74.125.225.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="W/gmp0eW"
Received: by mail-wm2-f13.google.com with SMTP id 5b1f17b1804b1-49b912e4b11so1113565e9.3
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 20:18:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789701506; cv=none;
        d=google.com; s=arc-20260327;
        b=Gh0hgQUmdFzpDDbyZckUYcccgFnXPez0ttPg5vyKEIT0HWbtFAFKGc+q1fnRKPh7JP
         3JgABS3r/4y0mTCvZrNoZCArU0Csb8IeFzRjz3T6iLth/O3QmdlQMrIjsig1NP6W+K8R
         mihYIjbTv9YmziIxc++R7HmpFt2U7rqzOc4UHV5K8OrgrlPVqnBVLKffKZm8wLztiM6u
         +TGqtaiUz7Y7Qcxh8pHnRccnqdDSJVkW0JUKQ/IAnqwgLrn3vSRcyLWrVvyTLmiK1OaQ
         gD8tJNXJP+OzCBnSCE0eRem4DdNyPIEhFWiTHPOjQR19fxfOA8KPXWGcD3D06r5CvftY
         zLlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=za06zza0SSiyVOfGkgQp3ziPhEo+75L0PjkgD2oGrhw=;
        fh=uL/QhY/NYjQfPtyVcb4puGWlANjb9bGfTK+F4PwUreE=;
        b=Ee+lnvGSh7lHEdLK6jxEaRIJ6uWKH2+xeegBfDN05AlhISnGE8ki8LdSbx2Hl7IgV+
         MtHs5H5M4JE59f3RNaGW5sh4IN5RklO6kF8F/c3O4+9nLlRjSpm1yh+CtIJkApk1xxzg
         0QXywprdFSEwwdzCodiHX9rWvsPGAFVnPNbAJqnmqLJsc+He5OWl1oRpy/wHB1VUHBy2
         aNU0SUZuIBKM9dumcHZNjpWcKuKgIfTGCM1y5f+0ae83yEGZhiH8AwT/J/RNcupmuTnf
         BWOrNxH2MqgOLO1Ef1j0fl4TZF4Z4ZSv4dAnA2ENXbi3nurDTZ7CBbycsVCbaOtldqvA
         O29Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1789701506; x=1790306306; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=za06zza0SSiyVOfGkgQp3ziPhEo+75L0PjkgD2oGrhw=;
        b=W/gmp0eWX/MPVMTj8+OPD1QW5SuL3WFjADvI5tzYPQtD2mpxKNPGUOkQx0aHYMMucF
         b1PHCRQoiy5/2yl+6d7jWvxFeD17vJs1qi/6KnGPqvq6k67TlxT2dGtgtUp1EI7AswM/
         GvHMDgv9/myy4pT6aYel7nP3hb+YoUVc0TbP4LBls7tCTLDHBemVBEvO9BLno0AeujZb
         Pbqkz1ZRsqvsxqTEWq91omKcXNnWLbE0VKjX6dCqTVACbpecLyBysFs76rdFg7wKFPkF
         voLbNF3CckqAFIcCh/uwXD7ZyJ2T60v535qNnmmsBzZ53t4np9qMt9MKOaWGMuhe6nmo
         NzQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789701506; x=1790306306;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=za06zza0SSiyVOfGkgQp3ziPhEo+75L0PjkgD2oGrhw=;
        b=QWNEv8W24Dmgbyt8zBdZgdtGQL+DrocNrRHXrsZVA5IOs8DfhCC2vGCen5xJbj9HNT
         2aBITRLTxvHOT1cr8iAsOYJ2Brnsx46WwgllfRr6W2kOwdIPRnnFJHQNOJoaGWl5vOhm
         5tMkfbkBOa5hi1DmznOECwDMkhKyIvwi3JfVLfA2VILN+d7Q9TKiiwsKCfr3rmtHvZfK
         siGJF44WR62aZyEAC3VVYM5TkB0Yz/UQfrCmzhKulVE/B4Qt3MAvC4PExcKYo232X554
         WaKkkVxSde9kmRqYrsRsnwGTHVGUr8w+P4CSD134KV+A6mb42hwI6MHGDDjYZ+DmSVaK
         bFzA==
X-Gm-Message-State: AFuF++kzp9dGezSKSUu9VRocH6WFV/f5w62LMunyMtZ7OuvbLMj5yyHP
	pX7IEqs+SJJk4OYQVBTwHBYvpyAkZWESdLysdtuHGFZBQDrOe2ow5MbPhPTuO19n+Wd4mPgI3+/
	UIWpFMjFkDn2G3A3TweRA1f4d9fUJh8Nl/SClQJmZIKtBXDfacTkq2AroIw==
X-Gm-Gg: AYBFou2GubKF9iCemmbs1bDYmIxOyqpB7rQMGBXoTnpeHk7pin2D2B6E0oInMZLKsq4
	iU7fB3ZUdGej6asihcbeopK+HWjY+M7AN9KfOO7qGrOtINArGOAzcHlCTIizK0gVUuNRuDuza53
	6WuPMv/KpoNtH5v1aT6GY8Uq45oyQSxsY00aQqDGLAQFdT7iIGKewXRVOXj2+F3q7JOdXJmEEn/
	xLmJLw9fapBHpQseAtBrvzuy7PQAtJ6RCXSNJWNpUESK6dvOUTv6i1DcAB+uLIjwF946/udX1Aq
	H3EWzFmvHPIpUV/arCHSJ2THG1zLTvbHuNk8bRYI3Synj3c3DMxAAg==
X-Received: by 2002:a05:600c:1382:b0:49d:174e:2a1e with SMTP id
 5b1f17b1804b1-49fc574f42bmr8693865e9.19.1789701506543; Thu, 17 Sep 2026
 20:18:26 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CABc6Dy5mvvCSECx2z+-L1q6FpQGO_hQfoLaS6vtpWVud6+8zbA@mail.gmail.com>
In-Reply-To: <CABc6Dy5mvvCSECx2z+-L1q6FpQGO_hQfoLaS6vtpWVud6+8zbA@mail.gmail.com>
From: "Sirisha Mylavarapu (she/her)" <smylavarapu@everpuredata.com>
Date: Fri, 18 Sep 2026 08:48:14 +0530
X-Gm-Features: AcwNN1XG90oBANrykcFZ_7ROc-Oon6P2rE-3lMGfvVQh3SJlhn1EW0r2wCO7LMM
Message-ID: <CABc6Dy5bmX+gA_UuHy3T-9xnY6sZ619SWq4FF1JAmWdCwTjb3w@mail.gmail.com>
Subject: Re: cgroup v2 io.max throttling works for NFSd reads but not writes
To: linux-nfs@vger.kernel.org
Cc: cgroups@vger.kernel.org, snitzer@kernel.org, chuck.lever@oracle.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

Gentle ping =E2=80=94 would appreciate any thoughts or pointers on this.

Thanks,
Sirisha

On Wed, Sep 16, 2026 at 12:29=E2=80=AFPM Sirisha Mylavarapu (she/her)
<smylavarapu@everpuredata.com> wrote:
>
> Hi,
>
> I have been experimenting with cgroup v2 io.max throttling for NFSd on
> kernel 7.0.0-14-generic (Ubuntu 26.04) and I wanted to share results
> and ask for recommendations.
>
> Goal: Throttle NFS server I/O bandwidth using cgroup v2 io.max by
> placing nfsd kernel threads in a dedicated cgroup, to limit block
> device I/O performed by the NFS server.
>
> Setup:
>
> -NFSd direct I/O mode enabled via debugfs (io_cache_read=3D2, io_cache_wr=
ite=3D2).
> -All 16 [nfsd] kernel threads moved to a dedicated cgroup
> (system.slice/nfsd.slice)
> -io.max throttle set to 50 MB/s on underlying block device (sdb,64GB
> disk, major:minor 8:16).
> -NFS export mounted locally via loopback for testing.
> -fio used for benchmarks
>
>
> Results:
> Read throttling works as expected, consistently capped at 50 MB/s.
> Write throttling doesn't work regardless of io_cache_write mode(tried
> DIRECT=3D2 and DONTCACHE=3D1).
>
> Root cause (as I understand it): The NFS client buffers writes in the
> local page cache and returns immediately to the application. The
> actual disk write happens asynchronously, so the application never
> waits for data to reach disk =E2=80=94 meaning the throttle does not prov=
ide
> backpressure to the writer even when the nfsd cgroup's io.max is
> active.
>
> Questions:
> 1. Is NFSd write throttling via cgroup v2 io.max a known limitation?
> Is there active upstream work to address this?
> 2. Are there any known workarounds or recommended approaches to
> achieve NFS write I/O throttling at the server side?
>
> Any pointers to upstream patches or LKML threads would be appreciated.
>
> Experiment:
> 1. Load nfsd module
>
> root@smylavarapu-16-0:~# modprobe nfsd
> root@smylavarapu-16-0:~# ls /sys/kernel/debug/nfsd
> disable-splice-read  io_cache_read  io_cache_write
>
> 2. Enable Direct I/O mode
>
> root@smylavarapu-16-0:~# echo 2 > /sys/kernel/debug/nfsd/io_cache_read
> root@smylavarapu-16-0:~# echo 2 > /sys/kernel/debug/nfsd/io_cache_write
> root@smylavarapu-16-0:~# cat /sys/kernel/debug/nfsd/io_cache_read
> 2
>
> 3. Start NFS server and verify nfsd kernel threads
>
> root@smylavarapu-16-0:~# systemctl start nfs-server
> root@smylavarapu-16-0:~# ps aux | grep '\[nfsd\]'
> root  662609  0.0  0.0  0  0 ?  I  10:48  0:00 [nfsd]
> root  662610  0.0  0.0  0  0 ?  I  10:48  0:00 [nfsd]
> ... (16 threads total, PIDs 662609=E2=80=93662624)
> root@smylavarapu-16-0:~# cat /proc/$(pgrep -x nfsd | head -1)/cgroup
> 0::/
>
> 4. Format and mount real block device (sdb)
>
> root@smylavarapu-16-0:~# mkfs.ext4 /dev/sdb
> mke2fs 1.47.2 (1-Jan-2025)
> Discarding device blocks: done
> Creating filesystem with 16777216 4k blocks and 4194304 inodes
> ...done
> root@smylavarapu-16-0:~# mount /dev/sdb /nfs-test-export
> root@smylavarapu-16-0:~# ls -la /dev/sdb
> brw-rw---- 1 root disk 8, 16 Sep 15 14:02 /dev/sdb
> major:minor =3D 8:16
>
> 5. Export over NFS and mount locally
>
> root@smylavarapu-16-0:~# echo "/nfs-test-export
> *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
> root@smylavarapu-16-0:~# exportfs -ra
> root@smylavarapu-16-0:~# exportfs -v
> /nfs-test-export
> <world>(sync,wdelay,hide,no_subtree_check,sec=3Dsys,rw,secure,no_root_squ=
ash,no_all_squash)
> root@smylavarapu-16-0:~# mkdir -p /mnt/nfs-client
> root@smylavarapu-16-0:~# mount -t nfs 127.0.0.1:/nfs-test-export /mnt/nfs=
-client
> root@smylavarapu-16-0:~# df -h /mnt/nfs-client
> Filesystem                  Size  Used Avail Use% Mounted on
> 127.0.0.1:/nfs-test-export   63G  2.0M   60G   1% /mnt/nfs-client
>
> 6. Move nfsd threads to dedicated cgroup
>
> root@smylavarapu-16-0:~# mkdir -p /sys/fs/cgroup/system.slice/nfsd.slice
> root@smylavarapu-16-0:~# cat /sys/fs/cgroup/system.slice/cgroup.subtree_c=
ontrol
> cpuset cpu io memory hugetlb pids rdma misc dmem
> root@smylavarapu-16-0:~# echo "+io" >
> /sys/fs/cgroup/system.slice/cgroup.subtree_control
> root@smylavarapu-16-0:~# for pid in $(pgrep -x nfsd); do
>     echo $pid > /sys/fs/cgroup/system.slice/nfsd.slice/cgroup.procs
> done
> root@smylavarapu-16-0:~# cat /proc/$(pgrep -x nfsd | head -1)/cgroup
> 0::/system.slice/nfsd.slice
>
> 7. Apply 50 MB/s throttle
>
> root@smylavarapu-16-0:~# echo "8:16 wbps=3D52428800 rbps=3D52428800" >
> /sys/fs/cgroup/system.slice/nfsd.slice/io.max
> root@smylavarapu-16-0:~# cat /sys/fs/cgroup/system.slice/nfsd.slice/io.ma=
x
> 8:16 rbps=3D52428800 wbps=3D52428800 riops=3Dmax wiops=3Dmax
>
> 8. Write test =E2=80=94 io_cache_write=3D2
>
> root@smylavarapu-16-0:~# fio --name=3Dnfs-write --rw=3Dwrite --bs=3D1M --=
size=3D4G \
>     --filename=3D/mnt/nfs-client/testfile --group_reporting --runtime=3D3=
0
> --time_based
> WRITE: bw=3D1761MiB/s (1847MB/s), io=3D52.0GiB, run=3D30236msec
> =E2=86=92 NOT throttled (1761 MB/s)
>
> 9. Write test after drop_caches =E2=80=94 io_cache_write=3D2
>
> root@smylavarapu-16-0:~# echo 3 > /proc/sys/vm/drop_caches
> root@smylavarapu-16-0:~# fio --name=3Dnfs-write --rw=3Dwrite --bs=3D1M --=
size=3D4G \
>     --filename=3D/mnt/nfs-client/testfile --group_reporting --runtime=3D3=
0
> --time_based
> WRITE: bw=3D2315MiB/s (2427MB/s), io=3D68.1GiB, run=3D30127msec
> =E2=86=92 NOT throttled (2315 MB/s)
>
> 10. Read test =E2=80=94 io_cache_read=3D2
>
> root@smylavarapu-16-0:~# echo 3 > /proc/sys/vm/drop_caches
> root@smylavarapu-16-0:~# fio --name=3Dnfs-read --rw=3Dread --bs=3D1M --si=
ze=3D4G \
>     --filename=3D/mnt/nfs-client/testfile --group_reporting --runtime=3D3=
0
> --time_based
>
> READ: bw=3D50.0MiB/s (52.4MB/s), IOPS=3D49, io=3D1501MiB, run=3D30032msec
> =E2=86=92 THROTTLED (capped at 50 MB/s)
>
> Thank you,
> Sirisha.
