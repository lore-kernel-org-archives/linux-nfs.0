Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57550 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751612Ab1ANCck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jan 2011 21:32:40 -0500
Message-ID: <4D2FB6F4.6070304@cn.fujitsu.com>
Date: Fri, 14 Jan 2011 10:37:40 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: hce <webmail.hce@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: mac error
References: <AANLkTin04TeswNAM89ij84YzfeTAR7rsppGyZFfq01qM@mail.gmail.com>
In-Reply-To: <AANLkTin04TeswNAM89ij84YzfeTAR7rsppGyZFfq01qM@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



hce :
> Hi,
> 
> I am running nfs server on a CentOS 5, it works fine for all
> connections from linux, windows clients. Mac clients worked fine for
> coping some regular files, but it could not copy mac packaging file
> with the extension *.dmg, it stuck with an error "nfs server lockd not
> responding", at the same time the server got a log message of
> "rpc.statd[2448]: Can't callback linux_server (100021,4), giving up".
> 
> Appreciate advice what could cause that problem and how could fix it?

Hi hce,

You use NFSv3, 
the NFSv3's file lock service depend on NLM(Network Lock Manager),
that need a user space program named rpc.statd to support service
like this:

           |     nfs client     |      nfs server 
-------------------------------------------------
           |                    |
user space |     rpc.statd    <--->      rpc.statd
           |        ^           |            ^
--------------------|------------------------|----
           |        v           |            v
kernel     |      lockd       <--->       lockd

when your nfs client is a MAC, maybe Mac's user space don't support
a program as rpc.statd, or you don't make the program run correctly.

Maybe you can use NFSv4 to avoid this problem.


-- 
----
thanks
Mi Jinlong

