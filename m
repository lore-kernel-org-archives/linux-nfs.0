From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Date: Sat, 20 Aug 2011 03:01:47 +0100
Message-ID: <20110820020147.GE2203@ZenIV.linux.org.uk>
References: <20101018223540.GA20730@gradator.net>
 <20110819230344.GA24784@gradator.net>
 <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
 <20110820012943.GD2203@ZenIV.linux.org.uk>
 <20110819184311.b094d6b7.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>,
	Sylvain Rochet <gradator@gradator.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110819184311.b094d6b7.rdunlap@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 19, 2011 at 06:43:11PM -0700, Randy Dunlap wrote:

> What do you suggest as a functioning alternative to inotify?

Depends on what particular (ab)use do you have in mind...
