From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [1/2] 2.6.23-rc3: known regressions with patches
Date: Mon, 13 Aug 2007 20:42:04 +0200
Message-ID: <20070813184204.GA6071@one.firstfloor.org>
References: <46C09C1A.7050706@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	Satyam Sharma <satyam.sharma@gmail.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Dan Merillat <dan.merillat@gmail.com>,
	Paolo Ornati <ornati@fastwebnet.it>,
	Andi Kleen <andi@firstfloor.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Jeff Garzik <jeff@garzik.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <46C09C1A.7050706@googlemail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> Unclassified
> 
> Subject         : reset during bootup - 2.6.23-rc2 (git d23cf676)

This is already fixed in mainline

There is a real regression with failing builds on some old binutils on 
x86-64 know, but I don't know how to fix it.

-Andi
