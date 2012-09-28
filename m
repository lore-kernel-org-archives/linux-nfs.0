Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34860 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758258Ab2I1RC4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Sep 2012 13:02:56 -0400
Received: by padhz1 with SMTP id hz1so2447507pad.19
        for <linux-nfs@vger.kernel.org>; Fri, 28 Sep 2012 10:02:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5064481D.8080006@netapp.com>
References: <1348687553-8461-1-git-send-email-bjschuma@netapp.com>
 <CAJ75kXZHD9nkL_bEzqd-L=5OVmxQjEwgPT_2Oj2pfCjfMdK_5w@mail.gmail.com> <5064481D.8080006@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 28 Sep 2012 19:02:34 +0200
Message-ID: <CAJ75kXb3WCj_COWhgwX7W2aCrNsHYK1iPiBGAxF6xwbVKzq0fA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] NFS: Remove bad delegations during open recovery
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 27, 2012 at 2:35 PM, Bryan Schumaker <bjschuma@netapp.com> wrote:
> Awesome!  Let me know how your tests go, thanks.

Oh I didn't saw it was nfs4.1 specific since the header shows "NFS:
Remove bad delegations during open recovery"
Sorry, I thought about a general nfs bug.

Regards,
-- 
William
