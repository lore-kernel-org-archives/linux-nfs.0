From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 19 Sep 2002 19:20:48 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020919.192048.80494959.davem@redhat.com>
References: <20020920040619.A30304@wotan.suse.de>
	<20020919.190154.57630807.davem@redhat.com>
	<20020920042819.A1289@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: akpm@digeo.com, taka@valinux.co.jp, alan@lxorguk.ukuu.org.uk,
	neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: ak@suse.de
In-Reply-To: <20020920042819.A1289@wotan.suse.de>
List-ID: <nfs.lists.sourceforge.net>

   From: Andi Kleen <ak@suse.de>
   Date: Fri, 20 Sep 2002 04:28:19 +0200
   
   You cannot really use these instructions on Athlon,

I know that Athlon lacks these instructions, they are p4 sse2
only.
