Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA7284A8FC4
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 14:13:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788531233; cv=none; b=M3ZX509bbTi+NFlygpJr88T66zzqRvxlki6+lYrdUpdLhAVqMAJulBUR7gjKfeUh+0/8QI4WxdKUPlMZ1EJI9T4h31E55K3BAaApu2QyFf359umrSCxnLBwfFX3iKOT93AkYlS2I+uQRNIyJNXj+OUNhyC4cYyTwcAUlbH8KINc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788531233; c=relaxed/simple;
	bh=6exO+MBsAsOuoyElfrPHMdb5rvloABvsC7vvffTUGy4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=L3zyuW53iuNWOCaZPm1p3+J/YkBtMFgU/kZqzImWYvhqtgVQt+utyzp9ZQeiIYLLy+Xmbl2/wR+iHY2+cenrTSkBonShL5MSfUD1c/1/fTouvuUYGZxgXIbXC9hM+YCk2arUozaAlwB/hjoDbhUskELUwsNyW93LAxeC8LVc3xs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BfgE3IJM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BfgE3IJM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 373BE1F00A3F;
	Fri,  4 Sep 2026 14:13:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788531231;
	bh=ySOtHFi/YBNps+4BpB+816EO/4fG1JPnmOJ76kn+tTo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=BfgE3IJMKOOVvAcKLN3u9RKRzjEMrSshuQwMdI3Ulu4SodGSJmNVJCzIRH8qw/BDs
	 HdKKArISdi8Lv/yZGKWSoKZ2KhWwPzQpKhIw0TFJ0ygGei+z2IyT8H6yh3U98liBt4
	 vo0J9gRyJGuQTTFPG/F8LjHvCTHi+ISlq90+CNsotOs7blMu4kx84GPvD4tP68IzZO
	 K+9r7XeW65gfw44RL5DgO8JRUoRlGKjYfZzYNTHIUAAkbayp6H22yd6LRfmBnzHllW
	 CsnI7/Hm0zbiLr3ZIIN4Net/v0SPAw7wSA2PxypeHvhWWCtqJcI4Qjf+k9AuIWH925
	 z7JJATnAX8e+Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 29AB7F40066;
	Fri,  4 Sep 2026 10:13:50 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 04 Sep 2026 10:13:50 -0400
X-ME-Sender: <xms:HtKaasHi0ssJRTpj5v23xkaf8T_vvE_a0XTN3UuH1p9jtE_b0EoPxw>
    <xme:HtKaagLG_oNWH7az727iZ7XB-R1GX7GxZsVC-R9YX-VtGq6lq41OnenESX5Ty-FsH
    0YYZV0ZWq1ySr31UdVW4J0D1jQ2nt1Qd-_IZRxYAxECYj_uHT4JvQS6AA>
X-ME-Proxy-Cause: dmFkZTF1d1qNF1wIFORUJTx3UI7czRiBK5SCUgzWJS3aDj/BZxCrRNt2/Jv7Icgp4gGouO
    ZXSYbrKU7wWN6Vk/DLjf5c0qv8pBzRTjAD92gcuk85nGhR0OewgTx65L5Ue3KxAstUJmLy
    tzujhu/FRFKp7fY8bOcYehNowe+fo24ZsdfqEjJYuvueQ7xqxSsyq5emGGNP4gKlbKdPNU
    YP3HKzfnvQ6ocKUGd1IwsV1zdgrNMhaqQYhmlIrCZ1bwEwauaO3yhAtvtluyRf/9NFbFru
    IG6a4Sxq336gWx4ZDVs82aQ0IQnaq0sIet89y3yVtIzE7Q3ZmlqnJTdbI5+SWvaEIeVihP
    2tQswfNf5kBNZTm97ZB9K1kviCja/ozEPoO+y6vmA6DihR/3Of159teLNkxK7L02i7tJYu
    CjPhXfUO4vekHwqs2RyJ/9xJD7uWoPu6kwXsErnes50qFyvkpLH+vqBzTttFt0E3VpTsHB
    Sj8EEjPkUhYZjQoGC4HP45YpK9KhtPuSqTKZ6fmnYVo+tMlZ9BMTPA0EpGQNYYLH3196QX
    IPoFNsZrUu0odILtxjAiTFn8IxRAU2sfi6ulj9SdeQLkNIHoFXT5+5oCKiGuf3ZzrBlbkN
    gJ5OaIlzA+bvoPi3EnX4XYlNKbGEm6QSIUYL50qS51vQJm8g+W5XIcw1tyCA
X-ME-Proxy: <xmx:HtKaasWo0A2bdtFXY_sZQieMNt1lsPMjNpoi3ysB2HdknaswKjR_tg>
    <xmx:HtKaahCQttal8rKh8azuTbifIO908qi-GnzrT-nJRYdpFsSErODBNg>
    <xmx:HtKaahGz8Og3QVcpi-5MuudxDVZLOE6zbAL3ci0EE2A4MGqO1xLptg>
    <xmx:HtKaai5r1bhsJZozFMEC8zfJaEXfPRQf99d63bInD-pO3hUXP1VOeQ>
    <xmx:HtKaankvOJfdbvCuVJ0aIXeToRbfOHOIOU8BThpSfNBdAj2hR-XuJ3d1>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 032F57811F0; Fri,  4 Sep 2026 10:13:50 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgpFG2YqzZmg
Date: Fri, 04 Sep 2026 10:13:28 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tejun Heo" <tj@kernel.org>,
 "Lai Jiangshan" <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <336623df-ead4-4802-91c5-aa3e785f2971@slotpi15m67>
In-Reply-To: <20260903235032.960219-1-tmenninger@everpuredata.com>
References: <20260831-performance-v1-6-8d9fd9b67f96@kernel.org>
 <20260902204048.4100864-1-tmenninger@everpuredata.com>
 <dc18f84a-f53f-440f-b0cb-f27b44e090eb@app.fastmail.com>
 <20260903235032.960219-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 3 Sep 2026, Tim Menninger wrote:
> The v2 series behaves similarly insofar as some runs see ~15 GB/s and
> other runs see ~45 GB/s, but the low-throughput state no longer appears
> to be directly controlled by the rpciod affinity scope.

Based on your follow-up, I have a theory about the bimodal performance
behavior:

> The substantial completion traffic in these captures is on
> 0000:2a:00.0. Its mlx5 completion IRQs are individually affinitized to
> CPUs. For example:
>
>     mlx5_comp0   -> CPU 0
>     mlx5_comp1   -> CPU 1
>     ...
>     mlx5_comp23  -> CPU 23
>     mlx5_comp24  -> CPU 48
>     ...
>     mlx5_comp47  -> CPU 71
>     mlx5_comp48  -> CPU 24
>     ...
>     mlx5_comp62  -> CPU 38

That is the mlx5 default spread. It fills the NIC's local NUMA node
first, both SMT threads, and overflows the remaining vectors onto the
other socket. If I read the numbering right, CPUs 0-23 and 48-71 are
the two threads of the node that 0000:2a:00.0 hangs off, and comp48
through comp62 land on the remote socket. Please confirm with:

    cat /sys/bus/pci/devices/0000:2a:00.0/numa_node
    lscpu | grep 'NUMA node'

rpcrdma.ko allocates a send and a receive completion queue for each
transport, and the RDMA core assigns the completion vector from a
host-global round-robin counter. The completion vector is selected at
transport connect time and is fixed for the life of the connection.

Completions on a remote vector run the CQ handler, the RPC reply
processing, and the rpciod wakeup all on the wrong socket. My
suggestion is that you should pin the NIC's interrupt vectors to
CPUs on the NIC's local node so that the round-robin cannot select
a remote one. Something like the following, adjusted once you have
confirmed the local CPU list:

    for irq in $(awk '/mlx5_comp(4[89]|5[0-9]|6[0-2])@pci:0000:2a:00.0/ \
                      { sub(":", "", $1); print $1 }' /proc/interrupts); do
        echo 0-23,48-71 > /proc/irq/$irq/smp_affinity_list
    done

Keep irqbalance disabled, since it will undo the interrupt steering.


-- 
Chuck Lever
