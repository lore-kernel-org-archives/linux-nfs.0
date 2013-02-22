Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27650 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754840Ab3BVOHi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2013 09:07:38 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: kernel crash with pNFS
Date: Fri, 22 Feb 2013 14:07:35 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DBA86@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAGue13qvwdi-3i1pbLYt-rVM=qsh1EVs2zEwNsGbTq2_C2dFkg@mail.gmail.com>
In-Reply-To: <CAGue13qvwdi-3i1pbLYt-rVM=qsh1EVs2zEwNsGbTq2_C2dFkg@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-02-22 at 10:44 +0100, Tigran Mkrtchyan wrote:
> Not much I can say. Data server was unavailable and client was
> receiving LAYOUT_TRYLATER many many times. And at the end....BUMM!
> Whatever we got attached.
> 
> Tigran.

Could that be the issue listed in this commit?
  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=085b7a45c63d3da5be155faab9249a5cab224561


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
