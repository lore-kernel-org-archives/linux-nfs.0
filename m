Return-Path: <SRS0=3Jq2=PS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91EC9C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 20:09:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6300A2173B
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 20:09:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729929AbfAJUJW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 10 Jan 2019 15:09:22 -0500
Received: from fieldses.org ([173.255.197.46]:48860 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729622AbfAJUJW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Jan 2019 15:09:22 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id BE514315; Thu, 10 Jan 2019 15:09:21 -0500 (EST)
Date:   Thu, 10 Jan 2019 15:09:21 -0500
To:     Guk-Bong Kwon <gbkwon@gmail.com>
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: There is no 'no space' message when using xfs with nfs.
Message-ID: <20190110200921.GB15492@fieldses.org>
References: <CAJ-WH_xqdJVyA7mMmoqAkbJoOcsvgm9cF--NQADfd+pp_oRbEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJ-WH_xqdJVyA7mMmoqAkbJoOcsvgm9cF--NQADfd+pp_oRbEw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Dec 09, 2018 at 10:07:26PM +0900, Guk-Bong Kwon wrote:
> i use xfs filesystem over nfs
> 
> 
> I am using the xfs file system via NFS on two Linux servers.
> 
> Even though xfs is full, you will not get a 'no space' message through nfs.
> 
> The server's load average goes up and the kworker consumes the CPU.
> 
> The server's nfs service is not responding.
> 
> When ext3 is full in the same environment, I get a 'no space' message.
> 
> Which part of nfs and xfs should be checked?

I don't know.  I'd be inclined to ask the xfs folks.  But 3.4 is 6 years
old, and they may want you to reproduce on more recent upstream.

It might help to look at the traffic in wireshark and try to figure out
which rpc calls are not getting responses from the server.

--b.

> 
> 
> Below is the environment I am using.
> 
> 
> kernel : nfs server 3.4.113 vanilla, nfs client 2.6.32-573.el6.x86_64
> 
> nfs : nfs v3 with tcp
> 
> 
> ==================================================================
> nfs server
> ==================================================================
> /dev/mapper/lv2  500G  500G   20K 100% /lv2
> 
> /lv2    0.0.0.0/0.0.0.0(rw,async,wdelay,nohide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,insecure_locks,no_acl,fsid=1543743056,anonuid=65534,anongid=65534)
> 
> 
> ==================================================================
> nfs client
> ==================================================================
> 10.0.0.20:/lv2   500G  500G   32K 100% /mnt/2
> 
> nfsstat  -m
> /mnt/2 from 10.0.0.20:/lv2
>  Flags: rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=10.0.0.20,mountvers=3,mountport=2047,mountproto=udp,local_lock=none,addr=10.0.0.20
> 
> 
> ==================================================================
> server top log
> ==================================================================
> top - 21:54:10 up 58 min,  0 users,  load average: 8.50, 8.37, 8.83
> Tasks: 347 total,   2 running, 345 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.0%us,  4.2%sy,  0.0%ni, 95.8%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
> 
>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
> 12368 root      20   0     0    0    0 S   12  0.0   4:32.44 kworker/2:2
> 11092 root      20   0     0    0    0 S   10  0.0   4:42.57 kworker/3:1
> 11166 root      20   0     0    0    0 R    9  0.0   2:09.47 kworker/5:1
> 12473 root      20   0     0    0    0 S    8  0.0   2:09.36 kworker/4:2
>  2944 root      20   0     0    0    0 D    6  0.0   2:09.10 nfsd
>  2953 root      20   0     0    0    0 D    6  0.0   2:24.65 nfsd
>  3024 root      20   0     0    0    0 D    6  0.0   2:23.12 nfsd
