From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: nfsd oops 2.6.7-rc1
Date: Fri, 28 May 2004 21:47:23 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040529044723.GA2093@holomorphy.com>
References: <20040529023550.GB2370@holomorphy.com> <16568.621.199870.484447@cse.unsw.edu.au> <20040529032540.GA1310@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262060AbUE2Erc@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>, akpm@osdl.org,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
In-Reply-To: <20040529032540.GA1310@holomorphy.com>
List-ID: <nfs.lists.sourceforge.net>

On Sat, May 29, 2004 at 01:24:29PM +1000, Neil Brown wrote:
>> Ok, I think I've found it.  There is a missing dget.  See below/.
>> NeilBrown

On Fri, May 28, 2004 at 08:25:40PM -0700, William Lee Irwin III wrote:
> Thanks! Testing ETA 10-15 minutes (time needed for kernel compiles).

No oopsen for 30 minutes so it's working wonderfully thus far, but I've
seen things go wrong a number of hours out from boot before. I'll try
to follow up with another ack after it's been longer.


-- wli
