From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: nfsd oops 2.6.7-rc1
Date: Fri, 28 May 2004 20:25:40 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040529032540.GA1310@holomorphy.com>
References: <20040529023550.GB2370@holomorphy.com> <16568.621.199870.484447@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263089AbUE2DZv@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16568.621.199870.484447@cse.unsw.edu.au>
List-ID: <nfs.lists.sourceforge.net>

On Friday May 28, wli@holomorphy.com wrote:
>> While idle, the following oops happened. On virgin 2.6.7-rc1.
>> 

On Sat, May 29, 2004 at 01:24:29PM +1000, Neil Brown wrote:
> Ok, I think I've found it.  There is a missing dget.  See below/.
> NeilBrown

Thanks! Testing ETA 10-15 minutes (time needed for kernel compiles).


-- wli
