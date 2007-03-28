From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Odd log message associated with NFS
Date: Wed, 28 Mar 2007 12:59:25 -0400
Message-ID: <20070328165925.GB21221@fieldses.org>
References: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com> <20070327193909.GA585@ds20.borg.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>,
	Phy Prabab <phyprabab@gmail.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933148AbXC1Q73@vger.kernel.org>
In-Reply-To: <20070327193909.GA585@ds20.borg.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Mar 27, 2007 at 07:39:10PM +0000, Thorsten Kranzkowski wrote:
> Mar 16 16:57:06 Marvin kernel: svc: bad direction 268435456, dropping request
> Mar 16 17:58:19 Marvin kernel: svc: bad direction 268435456, dropping request
> Mar 16 19:55:49 Marvin kernel: svc: bad direction 268435456, dropping request

So that's 2^28, in a field that should always be zero.  It's the very
first check of any data read from the rpc call, so it'd be consistent
with the call data being garbage, for one reason or another.

What would cause that to happen, I don't know.  Do you have a reliable
way to reproduce it?

--b.
