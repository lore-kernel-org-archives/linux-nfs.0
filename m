From: Ingo Molnar <mingo@elte.hu>
Subject: Re: linux-next: Tree for October 6
Date: Tue, 26 Oct 2010 10:08:22 +0200
Message-ID: <20101026080822.GA10520@elte.hu>
References: <20101006163632.c1943a38.sfr@canb.auug.org.au>
 <AANLkTimb2NxXcfj-o=F18S1u2rn-o851F+1sgQ_2uOVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Zimny Lech <napohybelskurwysynom2010@gmail.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <AANLkTimb2NxXcfj-o=F18S1u2rn-o851F+1sgQ_2uOVQ@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Zimny Lech <napohybelskurwysynom2010@gmail.com> wrote:

> 2010/10/6 Stephen Rothwell <sfr@canb.auug.org.au>:
> > Hi all,
> >
> > Changes since 20101005:
> 
> It looka like a bug or a beetle or something like that
> 
> /home/test/linux-2.6/fs/nfs/nfsroot.c: In function 'nfs_root_debug':
> /home/test/linux-2.6/fs/nfs/nfsroot.c:110:2: error: 'nfs_debug'
> undeclared (first use in this function)
> /home/test/linux-2.6/fs/nfs/nfsroot.c:110:2: note: each undeclared
> identifier is reported only once for each function it appears in
> make[3]: *** [fs/nfs/nfsroot.o] Error 1
> make[2]: *** [fs/nfs] Error 2
> make[1]: *** [fs] Error 2
> make: *** [sub-make] Error 2

This build bug has now been pushed upstream and triggers rather easily. Trond?

Thanks,

	Ingo
