From: Aaron Lehmann <aaronl@vitelus.com>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Wed, 18 Sep 2002 19:13:33 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020919021333.GC20500@vitelus.com>
References: <20020918.160057.17194839.davem@redhat.com> <1032393277.24895.8.camel@irongate.swansea.linux.org.uk> <3D89176B.40FFD09B@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <3D89176B.40FFD09B@digeo.com>
List-ID: <nfs.lists.sourceforge.net>

> akpm:/usr/src/cptimer> ./cptimer -d -s     
> nbytes=10240  from_align=0, to_align=0
>     copy_32: copied 19.1 Mbytes in 0.078 seconds at 243.9 Mbytes/sec
> __copy_duff: copied 19.1 Mbytes in 0.090 seconds at 211.1 Mbytes/sec

It's disappointing that this program doesn't seem to support
benchmarking of MMX copy loops (like the ones in arch/i386/lib/mmx.c).
Those seem to be the more interesting memcpy functions on modern
systems.
