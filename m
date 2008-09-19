From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: NFS root + iptables in 2.6.25
Date: Fri, 19 Sep 2008 02:00:57 -0700
Message-ID: <20080919020057.f2f256fe.akpm@linux-foundation.org>
References: <48D3451D.1080807@dgt.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Wojciech Kromer <wojciech.kromer-m/c5HOfTwvjVItvQsEIGlw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57505 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbYISJBE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Sep 2008 05:01:04 -0400
In-Reply-To: <48D3451D.1080807-m/c5HOfTwvjVItvQsEIGlw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Sep 2008 08:22:21 +0200 Wojciech Kromer <wojciech.kromer-m/c5HOfTwvjVItvQsEIGlw@public.gmane.org> wrote:

> Hi.
> 
> I'm using nfs root filesystem for developing.
> On 2.6.23 everything works fine, but on 2.6.25 loading any iptables
> module causes problems:
> 
> 
> # modprobe iptable_nat
> nf_conntrack version 0.5.0 (1024 buckets, 4096 max)
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> 
> 
> Probably iptables changed it's default behavior from "allow all" to
> "deny all" at startup.
> Is there any way to change it back?
> I can't change anything after loading any iptable module, because all
> programs on filesystem are not accessible after loading...
> 
> 

(cc's added)

(googles "nfs: RPC call returned error 1")

hm, there has been a dribble of reports going back several years, but
nothing conclusive afaict.

