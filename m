From: Pekka Enberg <penberg@gmail.com>
Subject: Re: [PATCH] remove redundant NULL pointer checks prior to calling kfree() in fs/nfsd/
Date: Sun, 27 Mar 2005 17:00:01 +0300
Message-ID: <84144f02050327060051b61e54@mail.gmail.com>
References: <Pine.LNX.4.62.0503252319220.2498@dragon.hyggekrogen.localhost>
	 <Pine.LNX.4.61.0503251731240.6372@chaos.analogic.com>
Reply-To: Pekka Enberg <penberg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesper Juhl <juhl-lkml@dif.dk>, Neil Brown <neilb@cse.unsw.edu.au>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, penberg@cs.helsinki.fi
To: linux-os@analogic.com
In-Reply-To: <Pine.LNX.4.61.0503251731240.6372@chaos.analogic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 25 Mar 2005 17:34:29 -0500 (EST), linux-os
<linux-os@analogic.com> wrote:
> You really should reconsider this activity. It is quite counter-productive.

No it's not. NULL is checked twice without Jesper's cleanups. If
kfree() calls are really that performance sensitive, just make it
inline and GCC will take care of it.

                                        Pekka
