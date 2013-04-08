Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f173.google.com ([209.85.128.173]:37169 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935457Ab3DHNC6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2013 09:02:58 -0400
Received: by mail-ve0-f173.google.com with SMTP id cy12so5393756veb.32
        for <linux-nfs@vger.kernel.org>; Mon, 08 Apr 2013 06:02:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130408120625.GA9924@umich.edu>
References: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
 <CAJ75kXY-Yt_DNrKz7VfQPudw-1DkcKaK5dr3Wz7KmByyxwMSCQ@mail.gmail.com>
 <1365280195.3651.4.camel@leira.trondhjem.org> <CAJ75kXac4k07HMcbob2OmAhH4M+Dp1hmZbC+8uAZPB2AdrEbQw@mail.gmail.com>
 <20130408120625.GA9924@umich.edu>
From: William Dauchy <wdauchy@gmail.com>
Date: Mon, 8 Apr 2013 15:02:37 +0200
Message-ID: <CAJ75kXbU3X_LBR69LsV4hfFxK3UH4jc1S5M=0xcG=RC=jgQBkA@mail.gmail.com>
Subject: Re: [PATCH 0/2] Stable patches for NFSv4/4.1 trunking
To: Jim Rees <rees@umich.edu>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 8, 2013 at 2:06 PM, Jim Rees <rees@umich.edu> wrote:
> Every patch, no matter how "obviously" correct, carries a risk of
> introducing new bugs. Trond is responsible for weighing the risk of new bugs
> against the benefit of fixing old ones. He has a lot of experience doing
> this. If he makes a mistake, he takes the heat for your bugs. Introducing a
> new bug into stable is a lot worse than introducing one into -next.

agreed. I understand the point of view.

--
William
