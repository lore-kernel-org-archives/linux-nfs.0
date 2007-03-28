From: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>
Subject: Re: Odd log message associated with NFS
Date: Wed, 28 Mar 2007 19:05:36 +0000
Message-ID: <20070328190536.GB585@ds20.borg.net>
References: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com> <20070327193909.GA585@ds20.borg.net> <20070328165925.GB21221@fieldses.org>
Reply-To: dl8bcu@dl8bcu.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phy Prabab <phyprabab@gmail.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965661AbXC1TGB@vger.kernel.org>
In-Reply-To: <20070328165925.GB21221@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Mar 28, 2007 at 12:59:25PM -0400, J. Bruce Fields wrote:
> On Tue, Mar 27, 2007 at 07:39:10PM +0000, Thorsten Kranzkowski wrote:
> > Mar 16 16:57:06 Marvin kernel: svc: bad direction 268435456, dropping request
> > Mar 16 17:58:19 Marvin kernel: svc: bad direction 268435456, dropping request
> > Mar 16 19:55:49 Marvin kernel: svc: bad direction 268435456, dropping request
> 
> So that's 2^28, in a field that should always be zero.  It's the very

ahh. indeed. I didn't do the math, yet :)

> first check of any data read from the rpc call, so it'd be consistent
> with the call data being garbage, for one reason or another.
> 
> What would cause that to happen, I don't know.  Do you have a reliable
> way to reproduce it?

just sit and wait :-) 
I'll let a tcpdump run this evening and see if I can correlate the message
with anything. 

If you have a printk or other patch for me to try, just let me know.
 
bye,
Thorsten

-- 
| Thorsten Kranzkowski        Internet: dl8bcu@dl8bcu.de                      |
| Mobile: ++49 170 1876134       Snail: Kiebitzstr. 14, 49324 Melle, Germany  |
| Ampr: dl8bcu@db0lj.#rpl.deu.eu, dl8bcu@marvin.dl8bcu.ampr.org [44.130.8.19] |
