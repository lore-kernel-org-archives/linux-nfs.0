From: Ingo Molnar <mingo@elte.hu>
Subject: Re: linux-next: Tree for October 6
Date: Tue, 26 Oct 2010 14:41:13 +0200
Message-ID: <20101026124113.GA10872@elte.hu>
References: <20101006163632.c1943a38.sfr@canb.auug.org.au>
 <AANLkTimb2NxXcfj-o=F18S1u2rn-o851F+1sgQ_2uOVQ@mail.gmail.com>
 <20101026080822.GA10520@elte.hu>
 <1288096333.3123.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Charles Edward Lever <Chuck.Lever@oracle.com>,
	Zimny Lech <napohybelskurwysynom2010@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1288096333.3123.9.camel@heimdal.trondhjem.org>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Anyhow, does the following fix the bug?

Thanks, trying it.

> Stephen Rothwell reports:
> 
> > /home/test/linux-2.6/fs/nfs/nfsroot.c: In function 'nfs_root_debug':
> > /home/test/linux-2.6/fs/nfs/nfsroot.c:110:2: error: 'nfs_debug'
> > undeclared (first use in this function)
> > /home/test/linux-2.6/fs/nfs/nfsroot.c:110:2: note: each undeclared
> > identifier is reported only once for each function it appears in
> > make[3]: *** [fs/nfs/nfsroot.o] Error 1
> > make[2]: *** [fs/nfs] Error 2
> > make[1]: *** [fs] Error 2
> > make: *** [sub-make] Error 2
> 
> Which is caused by commit 306a075362a288683f6346185f97dd0e06df19da
> (NFS: Allow NFSROOT debugging messages to be enabled dynamically)
> 
> Fix is to disable this code when RPC_DEBUG is disabled.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

The commit also needs this tag:

  Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>

Thanks,

	Ingo
