Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56113 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935338Ab3DHMGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Apr 2013 08:06:33 -0400
Date: Mon, 8 Apr 2013 08:06:25 -0400
From: Jim Rees <rees@umich.edu>
To: William Dauchy <wdauchy@gmail.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: [PATCH 0/2] Stable patches for NFSv4/4.1 trunking
Message-ID: <20130408120625.GA9924@umich.edu>
References: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
 <CAJ75kXY-Yt_DNrKz7VfQPudw-1DkcKaK5dr3Wz7KmByyxwMSCQ@mail.gmail.com>
 <1365280195.3651.4.camel@leira.trondhjem.org>
 <CAJ75kXac4k07HMcbob2OmAhH4M+Dp1hmZbC+8uAZPB2AdrEbQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJ75kXac4k07HMcbob2OmAhH4M+Dp1hmZbC+8uAZPB2AdrEbQw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

William Dauchy wrote:

  On Sat, Apr 6, 2013 at 10:29 PM, Myklebust, Trond
  <Trond.Myklebust@netapp.com> wrote:
  > The main reason is that it should be a _very_ rare event, since it
  > requires a call to try_to_get_module(THIS) to fail, and so I can't see
  > that it could ever cause a huge leakage.
  > If someone can show that it is more of a problem than I suggest above,
  > then I'm happy to reconsider.
  
  Understood. I didn't know a patch fixing a very rare event could not
  go in stable.

Every patch, no matter how "obviously" correct, carries a risk of
introducing new bugs. Trond is responsible for weighing the risk of new bugs
against the benefit of fixing old ones. He has a lot of experience doing
this. If he makes a mistake, he takes the heat for your bugs. Introducing a
new bug into stable is a lot worse than introducing one into -next.
