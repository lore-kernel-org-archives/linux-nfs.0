Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from prodfix-out0.dnb.de ([193.175.100.144]:39663 "EHLO mail.dnb.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726295AbeITLan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Sep 2018 07:30:43 -0400
Subject: Re: Bump: NFS3 subsystem hung, Kernel alive
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: 'Jeff Layton' <jlayton@kernel.org>,
        "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
References: <069801bdc6004814ba33d69eb888c575@dnb.de>
 <20180919191326.GA14422@fieldses.org>
From: =?UTF-8?Q?Guido_J=c3=a4kel?= <G.Jaekel@DNB.DE>
Message-ID: <47c116c0-1ef5-7beb-1482-c1c6851e85a2@DNB.DE>
Date: Thu, 20 Sep 2018 07:49:00 +0200
MIME-Version: 1.0
In-Reply-To: <20180919191326.GA14422@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Bruce,

thank you for quick response. And yes - it's no an easy one for sure, therefore i really need your kernel gurus expertise!

We have no contract for Linux, it's based on Gentoo Linux at all: We are totaly free to try out anything you ask for. This "datacenter design" now is working for about 8 years using a whole bunch of kernel versions without any problem. The issue *may* have start to appear in 2018Q1, maybe with with changing to LTS 4.14 or with changes concerning the Spectre theme. It have happended two/tree times on different other container hosts this year acting in Test and Approval stage. Because of the shared NFS infrastructure, all using exactly the same kernel image and (template-sourced copies of) the same root image. 

This also some older rackservers (for Evaluation stage) with comparable smaller hardware. They just have "1GB"-NICs and there might be a clue that the issue may be forced there by heavy file IO workload. I have to re-check this.

Unfortunately, the Apache email infrastructure is problematic (don't accept some mail encodings), but in the end I was able to create an account and open an issue (https://bugzilla.linux-nfs.org/show_bug.cgi?id=328). But I still can't attach things to this, i just got some "internal error". Therefore, please ask and I'll send it via email. I have a photo of the "SysRq" console showing a locked task and a tcpdump of "port nfs" taken at the last event. I'm may send kernel config file, kernel image or whatever you need. 

thank you all in advance

Guido

Kernel history:

root@bladerunner14 ~ # ll /boot{,/_save}/kernel* -t | grep -v old
lrwxrwxrwx 1 root root   38 Sep 18 11:46 /boot/kernel -> kernel-genkernel-x86_64-4.14.65-gentoo
-rw-r--r-- 1 root root 5.3M Sep 18 11:46 /boot/kernel-genkernel-x86_64-4.14.65-gentoo
-rw-r--r-- 1 root root 5.3M Aug  8 12:31 /boot/kernel-genkernel-x86_64-4.14.61-gentoo
-rw-r--r-- 1 root root 5.3M May 24 12:58 /boot/kernel-genkernel-x86_64-4.14.43-gentoo
-rw-r--r-- 1 root root 5.3M Apr  9 12:20 /boot/kernel-genkernel-x86_64-4.14.32-gentoo
-rw-r--r-- 1 root root 4.5M Feb 27  2018 /boot/_save/kernel-genkernel-x86_64-4.9.84-gentoo
-rw-r--r-- 1 root root 4.5M Jan 23  2018 /boot/_save/kernel-genkernel-x86_64-4.9.76-gentoo-r1
-rw-r--r-- 1 root root 4.5M Nov 16  2017 /boot/_save/kernel-genkernel-x86_64-4.9.61-gentoo
-rw-r--r-- 1 root root 4.2M Jan  3  2017 /boot/_save/kernel-genkernel-x86_64-4.4.39-gentoo
-rw-r--r-- 1 root root 4.0M Oct  6  2015 /boot/_save/kernel-genkernel-x86_64-3.14.51-gentoo
-rw-r--r-- 1 root root 4.0M Aug 28  2015 /boot/_save/kernel-genkernel-x86_64-3.14.9-gentoo
-rw-r--r-- 1 root root 3.7M Jul 14  2014 /boot/_save/kernel-genkernel-x86_64-3.10.20-gentoo
-rw-r--r-- 1 root root 3.5M Oct 10  2013 /boot/_save/kernel-genkernel-x86_64-3.8.13-gentoo
-rw-r--r-- 1 root root 3.4M Apr 23  2013 /boot/_save/kernel-genkernel-x86_64-3.3.5-gentoo
-rw-r--r-- 1 root root 3.3M May 16  2012 /boot/_save/kernel-genkernel-x86_64-3.3.4-gentoo
-rw-r--r-- 1 root root 2.7M Dec  1  2010 /boot/_save/kernel-genkernel-x86_64-2.6.34-gentoo-r6

On 19.09.2018 21:13, 'J. Bruce Fields' wrote:
> That just looks hard to debug, unfortunately.  Have you tried asking
> Netapp, or do you have a support contract for your Linux clients?  Was
> there an older kernel that worked OK?
> 
