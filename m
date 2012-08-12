Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40796 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab2HLRse (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Aug 2012 13:48:34 -0400
Received: by pbbrr13 with SMTP id rr13so5896131pbb.19
        for <linux-nfs@vger.kernel.org>; Sun, 12 Aug 2012 10:48:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344615387.7696.1.camel@lade.trondhjem.org>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
 <1344535551-4412-3-git-send-email-bjschuma@netapp.com> <CAJ75kXaYhQ8_Vw72j1Am5AxhHATsoEaOzh6JXA=buqeN38-8xA@mail.gmail.com>
 <1344615387.7696.1.camel@lade.trondhjem.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Sun, 12 Aug 2012 19:48:13 +0200
Message-ID: <CAJ75kXajUXdV+ARTd=vfVOuoDjuo5KOKn8ujw6_12OgcQzGqcQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] NFS: Use kzalloc() instead of kmalloc() in the idmapper
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 10, 2012 at 6:16 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> No. This is a cleanup and so is not stable kernel material.

true; sorry for the glitch

-- 
William
