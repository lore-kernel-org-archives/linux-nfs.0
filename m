Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bossdog.realss.com ([211.157.114.130]:45308 "EHLO
	bossdog.realss.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756234Ab0I0PB4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 11:01:56 -0400
Message-ID: <4CA0B1DD.1000605@realss.com>
Date: Mon, 27 Sep 2010 23:01:49 +0800
From: Zhang Weiwu <zhangweiwu@realss.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org
Subject: Re: when will we be able to use LIPKEY on NFS4 on Linux?
References: <4CA05749.8070502@realss.com> <1285590266.19362.37.camel@heimdal.trondhjem.org>
In-Reply-To: <1285590266.19362.37.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010年09月27日 20:24, Trond Myklebust wrote:
>
> We're likely to drop the requirement that SPKM3/LIPKEY ...
>  SPKM3 mechanism (on which LIPKEY relies) appears
> to contain inherent security flaws that are difficult to fix.

Thanks for the clear answer. We have a few setups where an
infrastructure is close to not possible (Kerberos) thus at the moment we
are deciding between switching to samba for username/password
authentication from NFS or uses the long-expected LIPKEY. samba might
have other inherent security flaws but practically security is not a
priority of our concern at the moment. Your information is directly
helpful for making a decision:) thanks!
