Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:51093 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751515AbcGMPHJ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 11:07:09 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: ELOOP from getdents
References: <87lh1fizyy.fsf@thinkpad.rath.org>
	<87vb0a8oyc.fsf@thinkpad.rath.org>
	<E35BAE5E-4D9B-44B4-98B3-54BA36AC895B@primarydata.com>
Date: Wed, 13 Jul 2016 17:06:34 +0200
In-Reply-To: <E35BAE5E-4D9B-44B4-98B3-54BA36AC895B@primarydata.com> (Trond
	Myklebust's message of "Tue, 12 Jul 2016 23:26:00 +0000")
Message-ID: <87d1mh1ssl.fsf@thinkpad.rath.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 12 2016, Trond Myklebust <trondmy@primarydata.com> wrote:
> In NFSv4, offsets 1 and 2 are reserved:
> https://tools.ietf.org/html/rfc7530#section-16.24

Ah, that explains it. Thanks!

I was assuming that I could export any "proper" unix file system over
NFS - and as far as I know, the rest of the VFS does not make any
assumptions (or reservations) about readdir offsets. Are there other
such constraints? I looked at the RFC, but it's rather hard to extract
that specific information...

Best,
Nikolaus

-- 
GPG encrypted emails preferred. Key id: 0xD113FCAC3C4E599F
Fingerprint: ED31 791B 2C5C 1613 AF38 8B8A D113 FCAC 3C4E 599F

             »Time flies like an arrow, fruit flies like a Banana.«
