From: Andi Kleen <ak@suse.de>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Fri, 20 Sep 2002 04:35:49 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020920043549.A3047@wotan.suse.de>
References: <20020920040619.A30304@wotan.suse.de> <20020919.190154.57630807.davem@redhat.com> <20020920042819.A1289@wotan.suse.de> <20020919.192048.80494959.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, akpm@digeo.com, taka@valinux.co.jp,
	alan@lxorguk.ukuu.org.uk, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020919.192048.80494959.davem@redhat.com>
List-ID: <nfs.lists.sourceforge.net>

On Thu, Sep 19, 2002 at 07:20:48PM -0700, David S. Miller wrote:
>    From: Andi Kleen <ak@suse.de>
>    Date: Fri, 20 Sep 2002 04:28:19 +0200
>    
>    You cannot really use these instructions on Athlon,
> 
> I know that Athlon lacks these instructions, they are p4 sse2
> only.

AFAIK it is an SSE1 feature.

Athlon actually has movnti in newer models, just you do not really want to 
use it.

-Andi
