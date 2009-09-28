From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [linux-cifs-client] [RFC PATCH 0/9] sunrpc: teach the SUNRPC
 layer how to speak SMB
Date: Mon, 28 Sep 2009 09:06:12 -0400
Message-ID: <20090928090612.01fce486@tupile.poochiereds.net>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
	<4a4634330909271921o125c8303p64974d850007ed8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
To: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751609AbZI1LFn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 07:05:43 -0400
In-Reply-To: <4a4634330909271921o125c8303p64974d850007ed8b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 27 Sep 2009 21:21:40 -0500
Shirish Pargaonkar <shirishpargaonkar@gmail.com> wrote:

> On Sun, Sep 27, 2009 at 11:50 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > This patchset is still preliminary and is just an RFC...
> >
> > First, some background. When I was at Connectathon this year, Trond
> > mentioned an interesting idea to me. He said (paraphrasing):
> >
> > "Why doesn't CIFS just use the RPC layer for transport? It's very
> > efficient at shoveling bits out onto the wire. You'd just need to
> > abstract out the XDR/RPC specific bits."
> >
> > The idea has been floating around in the back of my head until recently,
> > when I decided to give it a go. This patchset represents a first, rough
> > draft at a patchset to do this. There's also a proof of concept module
> > that demonstrates that it works as expected.
> >
> > The patchset is still very rough. Reconnect behavior is still very
> > "RPC-ish", for instance. There are doubtless other changes that will
> > need to be made before I had anything merge-worthy.
> >
> > At this point, I'm just interested in feedback on the general approach.
> > Should I continue to pursue this or is it a non-starter for some
> > reason?
> >
> > The next step here, obviously is to start building a fs on top of it.
> > I'd particularly be interested in using this as a foundation of a
> > new smb2fs.
> >
> > I've also got this patchset up on my public git tree:
> >
> >    http://git.samba.org/?p=jlayton/cifs.git;a=summary
> >
> > Here are some questions I anticipate on this, and their answers:
> >
> > ------------------------------------------------------------------------
> > Q: Are you insane? Why would you attempt to do this?
> >
> > A: Maybe...but in the last couple of years, I've spent a substantial
> > amount of time working on the CIFS code. Much of that time has been
> > spent fixing bugs. Many of those bugs exist in the low-level transport
> > code which has been hacked on, kludged around and hand tweaked to
> > where it is today. Unfortunately that's made it a very hard to work
> > on mess. This drives away potential developers.
> >
> > CIFS in particular is also designed around synchronous ops, which
> > seriously limits throughput. Retrofitting it for asynchronous operation
> > will be adding even more kludges. The sunrpc code is already
> > fundamentally asynchronous.
> > ------------------------------------------------------------------------
> > Q: Okay, what's the benefit of hooking it up to sunrpc rather than
> > building a new transport layer (or fixing the transport in the other two
> > filesystems)?
> >
> > A: Using sunrpc allows us to share a lot of the rpc scheduler code with
> > sunrpc. At a high level, NFS/RPC and SMB aren't really very different.
> > Sure, they have different formats, and one is big endian on the wire and
> > the other isn't...still there are significant similarities.
> >
> > We also get access to the great upcall mechanisms that sunrpc has, and
> > the possibility to share code like the gssapi upcalls. The sunrpc layer
> > has a credential and authentication management framework that we can
> > build on to make a truly multiuser CIFS/SMB filesystem.
> >
> > I've heard it claimed before that Linux's sunrpc layer is
> > over-engineered, but in this case that works in our favor...
> > ------------------------------------------------------------------------
> > Q: can we hook up cifs or smbfs to use this as a transport?
> >
> > A: Not trivially. CIFS in particular is not designed with each call
> > having discrete encode and decode functions. They're sort of mashed
> > together. smbfs might be possible...I'm a little less familiar with it,
> > but it does have a transport layer that more closely resembles the
> > sunrpc one. Still though, it'd take significant work to make that
> > happen. I'm not opposed to the idea however.
> >
> > In the end though, I think we'll probably need to design something new
> > to sit on top of this. We will probably be able to borrow code and
> > concepts from the other filesystems however.
> > ------------------------------------------------------------------------
> > Q: could we use this as a transport layer for a smb2fs ?
> >
> > A: Yes, I think so. This particular prototype is build around SMB1, but
> > SMB2 could be supported with only minor modifications. One of the
> > reasons for sending this patchset now before I've built a filesystem on
> > top of it is because I know that SMB2 work is in progress. I'd like to
> > see it based around a more asynchronous transport model, or at least
> > built with cleaner layering so that we can eventually bolt on a different
> > transport layer if we so choose.
> >
> > Jeff Layton (9):
> >  sunrpc: abstract out encoding function at rpc_clnt level
> >  sunrpc: move check for too small reply size into rpc_verify_header
> >  sunrpc: abstract our call decoding routine
> >  sunrpc: move rpc_xdr_buf_init to clnt.h
> >  sunrpc: make call_bind non-static
> >  sunrpc: add new SMB transport class for sunrpc
> >  sunrpc: add encoding and decoding routines for SMB
> >  sunrpc: add Kconfig option for CONFIG_SUNRPC_SMB
> >  smbtest: simple module for testing SMB/RPC code
> >
> >  fs/Makefile                    |    2 +
> >  fs/lockd/host.c                |    4 +
> >  fs/lockd/mon.c                 |    4 +
> >  fs/nfs/client.c                |    4 +
> >  fs/nfs/mount_clnt.c            |    4 +
> >  fs/nfsd/nfs4callback.c         |    4 +
> >  fs/smbtest/Makefile            |    1 +
> >  fs/smbtest/smbtest.c           |  204 +++++
> >  include/linux/sunrpc/clnt.h    |   24 +-
> >  include/linux/sunrpc/smb.h     |   42 +
> >  include/linux/sunrpc/xprtsmb.h |   59 ++
> >  net/sunrpc/Kconfig             |   11 +
> >  net/sunrpc/Makefile            |    1 +
> >  net/sunrpc/clnt.c              |   98 ++-
> >  net/sunrpc/rpcb_clnt.c         |    8 +
> >  net/sunrpc/smb.c               |  120 +++
> >  net/sunrpc/sunrpc_syms.c       |    3 +
> >  net/sunrpc/xprtsmb.c           | 1723
> > ++++++++++++++++++++++++++++++++++++++++
> >  18 files changed, 2272 insertions(+), 44 deletions(-)
> >  create mode 100644 fs/smbtest/Makefile
> >  create mode 100644 fs/smbtest/smbtest.c
> >  create mode 100644 include/linux/sunrpc/smb.h
> >  create mode 100644 include/linux/sunrpc/xprtsmb.h
> >  create mode 100644 net/sunrpc/smb.c
> >  create mode 100644 net/sunrpc/xprtsmb.c
> >
> > _______________________________________________
> > linux-cifs-client mailing list
> > linux-cifs-client@lists.samba.org
> > https://lists.samba.org/mailman/listinfo/linux-cifs-client
> >
> 
> 
> Jeff,
> 
> So servers need to speak SUNRPC as well right?
> Are_threre/how_many servers are out there that speak CIFS/SMB over SUNRPC or
> SMB2 over SUNRPC?

No...sorry if that wasn't clear. The on the wire protocol is still the
same as cifs or smbfs talks. You could use this to talk to windows
servers for instance. The idea is to use the existing code in the Linux
kernel's sunrpc engine and teach it how to speak a new "dialect" on the
wire...the SMB or SMB2 protocol.

For example, to test this, I sent a NegotiateProtocol request to a
samba server over its normal port 445. No ONC-RPC required.

-- 
Jeff Layton <jlayton@redhat.com>
