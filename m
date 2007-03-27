From: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>
Subject: Re: Odd log message associated with NFS
Date: Tue, 27 Mar 2007 19:39:10 +0000
Message-ID: <20070327193909.GA585@ds20.borg.net>
References: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com>
Reply-To: dl8bcu@dl8bcu.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Phy Prabab <phyprabab@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965398AbXC0UeS@vger.kernel.org>
In-Reply-To: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Mar 27, 2007 at 11:40:48AM -0700, Phy Prabab wrote:
> Hello,
> 
> I am currently running 2.6.21-rc5 and I am seeing quite a bit of this
> message in my log files:
> kernel: rpcsvc: received unknown control message:-2144992132/-1
> 
> This machine is an dual dual core opteron with 3Ware 9650 (14 disk
> RAID10), 4G RAM, 64bit kernel, nfsutils-1.0.12 running knfsd.  This
> machine is a  file server.

Just a 'me, too':

Mar 16 16:57:06 Marvin kernel: svc: bad direction 268435456, dropping request
Mar 16 17:58:19 Marvin kernel: svc: bad direction 268435456, dropping request
Mar 16 19:55:49 Marvin kernel: svc: bad direction 268435456, dropping request
...
Mar 17 04:30:03 Marvin kernel: svc: bad direction 268435456, dropping request
Mar 17 06:28:52 Marvin kernel: pppd(795): unaligned trap at 0000020000207f90: 000000011fd8d33d 29 1
Mar 17 06:28:55 Marvin kernel: inet_sk_reselect_saddr(): shifting inet->saddr from 82.149.xxx.xxx to 89.166.xxx.xxx
Mar 17 09:05:21 Marvin kernel: rpcsvc: received unknown control message:-1024/186028080
Mar 17 14:17:04 Marvin kernel: rpcsvc: received unknown control message:-1024/186028040
Mar 17 14:17:31 Marvin kernel: rpcsvc: received unknown control message:-1024/186028040
Mar 17 14:49:14 Marvin kernel: rpcsvc: received unknown control message:-1024/186028080
Mar 17 14:49:15 Marvin kernel: rpcsvc: received unknown control message:-1024/186028040



This is from my little 'server', alpha ev4 'noname', 2.6.21-rc3, compiled 
with gcc 4.1.2

client is mostly an alpha ev6 2.6.21-rc3, gcc 4.1.2.

Apart from the messages NFS seems to run just fine currently.

Bye,
Thorsten 



-- 
| Thorsten Kranzkowski        Internet: dl8bcu@dl8bcu.de                      |
| Mobile: ++49 170 1876134       Snail: Kiebitzstr. 14, 49324 Melle, Germany  |
| Ampr: dl8bcu@db0lj.#rpl.deu.eu, dl8bcu@marvin.dl8bcu.ampr.org [44.130.8.19] |
