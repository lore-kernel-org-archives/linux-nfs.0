From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: nfs/nfsd gets stuck on a write
Date: Wed, 6 Aug 2003 13:16:34 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030806111634.GG703@wiggy.net>
References: <20030806104612.GB703@wiggy.net> <20030806110215.GA30936@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bert hubert <ahu@ds9a.nl>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
In-Reply-To: <20030806110215.GA30936@outpost.ds9a.nl>
List-ID: <nfs.lists.sourceforge.net>

Previously bert hubert wrote:
> I've had problems like that go away by explicitly mounting -o tcp. 

Mounting with -o tcp does indeed seem to be a working work-around. It
does feel a lot more sluggish/high latency than udp though.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.
