Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 93D9E47A87B;
	Thu,  8 Oct 2026 22:50:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791499844; cv=none; b=jAxhAa7ctzaTpKH2ZXcohURf8C2J7mtRiKgOFk2t7+MU/6u6x1CpuXvcMiF4AT8mhDshP/sa/fAiwp6R0DnTYZ3RJiFmPhcj9n5TnDLvTj23P/0e9N0h3SvJ3vwoHZK7m9FUGzI8lDZCtKRQWuSLsvY9Vn9TtsfFbLfPn0J7WQo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791499844; c=relaxed/simple;
	bh=GdprQ8WNnn/AthALDUCN2FHjSspovObyPhzLx36OaAQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ch6wglD0M62UszT5MaH9HI1AvVP03zFpp6NYDLtQWAinX34KSDfPlyI1/nCiRQlOjeapcOG3TExYKf2HVU+RhYVckyxPexxKqcAy52GGhvrJGNOJHCakPkRMGQCRKvf7T8t7keWD2C6Xc3v/WpXHcVqHajCT0gXDgOYBp+NQXUE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=T91qmQhw; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="T91qmQhw"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6E9171692;
	Thu,  8 Oct 2026 15:50:37 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E8B463F66F;
	Thu,  8 Oct 2026 15:50:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791499840; bh=GdprQ8WNnn/AthALDUCN2FHjSspovObyPhzLx36OaAQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=T91qmQhwgqMfI1mCyb/CnAj9ITI0uNFnOdI6ANAk1bg92YGuwSWwlGQeDp1f1YsGs
	 V96fpW4w4k8XShR5lhoN0+fJj9WW2ybqw29JxeFjNe0mlt00Irc6vY0tgUMd8mC4dE
	 7kKuwR735aWi4J2Va2Y+9B5mLbjZ3W931nGMPTHo=
From: J Louis Kaplan <Louis.Kaplan@arm.com>
To: cel@kernel.org,
	dai.ngo@oracle.com,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com
Cc: anna@kernel.org,
	jgg@ziepe.ca,
	leon@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	trondmy@kernel.org
Subject: Re: [RFC PATCH 0/6] Improve NFS server direct throughput with passthrough enabled
Date: Thu,  8 Oct 2026 23:50:30 +0100
Message-ID: <20261008225030.643512-1-Louis.Kaplan@arm.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <cbc3ff79-4866-4433-a01b-3d5eeab1962b@app.fastmail.com>
References: <cbc3ff79-4866-4433-a01b-3d5eeab1962b@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> Actually a similar approach has been tried before... And it had to be
> reverted

Thanks for sharing these useful links. They provide important context
that I was not aware of.

I'll have another read through the investigations and commit dates
to better understand the change timeline, but I wanted to share some
contention data I gathered prompted by your feedback.

During development of this patch series, I did notice lock contention
issues. I suspected the unbound workqueue but my analysis was shallow
and I didn't have a good idea how to improve the situation.

After a rebase I noticed a decrease in contention and found your commit
58202c29de936 in the git log which looked likely to be the beneficial
change.

I set up two test branches after reading your feedback. Both apply this
patch series (with minor conflict resolutions) to the older nfsd-testing
commit a39f0ce0c9da2 which reverts `Use contiguous pages for RDMA Read
sink buffers`. `ubwq` also reverts your patch 58202c29de936 whereas
`no-ubwq` does not.

For direct IO on the server and NFS reads in configuration A I mentioned
above (passthrough enabled), here are representative top lines of perf
contention data (spinlocks only).

ubwq (without 58202c29de936)
contended   total wait    max wait   avg wait   caller
   202787    588.67 ms   334.01 us    2.90 us   __rmqueue_pcplist+0x320
   281818    586.91 ms   267.99 us    2.08 us   free_pcppages_bulk+0x48
    88218    100.65 ms     5.57 us    1.14 us   rcu_report_qs_rdp+0x44
     1124     11.07 ms    28.13 us    9.85 us   tick_do_update_jiffies64+0x48
     5773      4.92 ms     3.42 us     851 ns   tmigr_update_events+0x184
     1274      2.38 ms    66.01 us    1.87 us   nfsd4_sequence_done+0x70
     1272      2.36 ms    51.23 us    1.86 us   nfsd4_sequence+0x114
     1074      2.05 ms     5.57 us    1.90 us   acpi_os_wait_semaphore+0x80
     1074      1.68 ms    15.68 us    1.56 us   free_pcppages_bulk+0x48
      739      1.04 ms     4.80 us    1.41 us   __queue_work+0xd4
      424    745.28 us     8.99 us    1.76 us   raw_spin_rq_lock_nested+0x3c
      362    649.74 us    18.78 us    1.79 us   __rmqueue_pcplist+0x320
    ... <truncated>

no-ubwq (with 58202c29de936):
contended   total wait   max wait   avg wait   caller
    68113     82.67 ms    5.92 us    1.21 us   rcu_report_qs_rdp+0x44
     1604      2.41 ms   21.73 us    1.50 us   nfsd4_sequence_done+0x70
     1689      2.31 ms   26.21 us    1.37 us   nfsd4_sequence+0x114
      884      1.66 ms   15.87 us    1.88 us   raw_spin_rq_lock_nested+0x3c
      153      1.21 ms   16.48 us    7.93 us   tick_do_update_jiffies64+0x48
      311    566.99 us   14.43 us    1.82 us   raw_spin_rq_lock_nested+0x3c
      423    459.48 us    2.98 us    1.09 us   force_qs_rnp+0x104
      185    335.12 us   27.14 us    1.81 us   __lwq_dequeue+0x34
       40    288.12 us   20.35 us    7.20 us   free_pcppages_bulk+0x48
      220    285.37 us    3.97 us    1.30 us   __queue_work+0xd4
      284    242.78 us    2.14 us     854 ns   tmigr_update_events+0x184
      153    216.64 us    3.10 us    1.41 us   acpi_os_wait_semaphore+0x80
      164    216.03 us   26.43 us    1.32 us   find_stateid_by_type+0x40
      143    206.07 us   13.66 us    1.44 us   nfsd4_sequence+0x238
       95    118.24 us    2.40 us    1.24 us   dma_pool_alloc+0x50
       85    116.29 us    2.75 us    1.37 us   acpi_os_signal_semaphore+0x88
       86    101.37 us    5.54 us    1.18 us   raw_spin_rq_lock_nested+0x3c
       34     84.18 us    8.45 us    2.47 us   mix_interrupt_randomness+0x104
       72     77.31 us    1.95 us    1.07 us   raw_spin_rq_lock_nested+0x3c
       43     74.94 us    4.29 us    1.74 us   raw_spin_rq_lock_nested+0x3c
       51     72.09 us    3.33 us    1.41 us   acpi_os_wait_semaphore+0x80
       62     67.26 us    1.92 us    1.08 us   dma_pool_free+0x3c
       42     61.66 us    2.46 us    1.47 us   acpi_os_wait_semaphore+0x80
       39     55.87 us    2.94 us    1.43 us   __queue_work+0xd4
       21     50.65 us   15.23 us    2.41 us   raw_spin_rq_lock_nested+0x3c
       35     45.76 us    2.05 us    1.31 us   raw_spin_rq_lock_nested+0x3c
       15     24.16 us    3.93 us    1.61 us   free_pcppages_bulk+0x48
    ... <truncated>

CPU usage was 7% lower in the no-ubwq branch. Throughput remained similar
in both branches for this test.

I'm still digesting the above (and more) data and trying to understand
how all the information fits together, but I wanted to share the above
in the meantime.
