From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 0/8] RDMA Transport Provider
Date: Fri, 30 Nov 2007 13:41:33 -0600
Message-ID: <1196451693.5432.35.camel@trinity.ogc.int>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int>
	 <20071130044553.GA29851@fieldses.org>
	 <1196438368.5432.10.camel@trinity.ogc.int>
	 <20071130171649.GC14943@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:59761 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755382AbXK3Th3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 14:37:29 -0500
In-Reply-To: <20071130171649.GC14943@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2007-11-30 at 12:16 -0500, J. Bruce Fields wrote:
> On Fri, Nov 30, 2007 at 09:59:28AM -0600, Tom Tucker wrote:
> > 
[...snip...]
> > 
> > I'm mystified as to why I didn't get these warnings. I built on a 64 bit
> > machine. It seems like that would give the warning since unsigned long
> > isn't even the same size as int.
> 
> Yeah, I can't see how any compiler could miss that.  How do you usually
> build?

>From emacs on my desktop...

ssh root@victim "cd /home/tom/src/linux-2.6 && ntpdate <servername> && make && make modules_install && make install"

The target system is an AMD64. Here's uname -a...

Linux demo1 2.6.24-rc3-merged-svc #12 SMP Fri Nov 30 08:51:15 CST 2007 x86_64 x86_64 x86_64 GNU/Linux

The compiler version..

gcc version 4.1.1 20070105 (Red Hat 4.1.1-52)

The output after changing the type back to int ...

ssh root@demo1 "cd /home/tom/src/linux-2.6 && ntpdate dell3 && make"
30 Nov 11:21:38 ntpdate[4155]: step time server 10.10.0.102 offset -1.150670 sec
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC [M]  net/sunrpc/svc_rdma.o
  CC [M]  net/sunrpc/svc_rdma_transport.o
  CC [M]  net/sunrpc/svc_rdma_marshal.o
  CC [M]  net/sunrpc/svc_rdma_sendto.o
  CC [M]  net/sunrpc/svc_rdma_recvfrom.o
  LD [M]  net/sunrpc/sunrpc.o
  LD [M]  net/sunrpc/svcrdma.o
Kernel: arch/x86/boot/bzImage is ready  (#12)
  Building modules, stage 2.
  MODPOST 1294 modules
  LD [M]  net/sunrpc/sunrpc.ko
  LD [M]  net/sunrpc/svcrdma.ko

No warning...

> 
> --b.

