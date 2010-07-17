From: Riccardo Tritto <riccardo.tritto@gmail.com>
Subject: Re: Permission issues
Date: Sat, 17 Jul 2010 15:08:19 +0200
Message-ID: <AANLkTimwXWglJE-GU6xUKPI9cjV-zgjPE2vzbND4p7N8@mail.gmail.com>
References: <AANLkTimNfc_NFfsdj1wApWzyIfsU5O2k4uoFEUCRx5Gq@mail.gmail.com>
	<1278866838.9537.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40412 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754540Ab0GQNIm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jul 2010 09:08:42 -0400
Received: by wyb42 with SMTP id 42so2802329wyb.19
        for <linux-nfs@vger.kernel.org>; Sat, 17 Jul 2010 06:08:40 -0700 (PDT)
In-Reply-To: <1278866838.9537.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2010/7/11 Trond Myklebust <trond.myklebust@fys.uio.no>:
> You are relying on being able to use more than 16 groups, but the SUN=
RPC
> protocol will not support that:
> =C2=A0http://nfsworld.blogspot.com/2005/03/whats-deal-on-16-group-id-=
limitation.html

I solved this problem using nfsv4 instead of v3.
Thank you for your suggestions.
