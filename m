From: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
Subject: Re: [RFC PATCH 0/9] sunrpc: teach the SUNRPC
	layer how to speak SMB
Date: Sun, 27 Sep 2009 21:21:40 -0500
Message-ID: <4a4634330909271921o125c8303p64974d850007ed8b@mail.gmail.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3782171883188185071=="
Cc: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-cifs-client-bounces@lists.samba.org>
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <https://lists.samba.org/mailman/options/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/linux-cifs-client>
List-Post: <mailto:linux-cifs-client@lists.samba.org>
List-Help: <mailto:linux-cifs-client-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=subscribe>
Sender: linux-cifs-client-bounces@lists.samba.org
Errors-To: linux-cifs-client-bounces@lists.samba.org
List-ID: <linux-nfs.vger.kernel.org>

--===============3782171883188185071==
Content-Type: multipart/alternative; boundary=001636c925643d092c047499f51c

--001636c925643d092c047499f51c
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Sep 27, 2009 at 11:50 AM, Jeff Layton <jlayton@redhat.com> wrote:

> This patchset is still preliminary and is just an RFC...
>
> First, some background. When I was at Connectathon this year, Trond
> mentioned an interesting idea to me. He said (paraphrasing):
>
> "Why doesn't CIFS just use the RPC layer for transport? It's very
> efficient at shoveling bits out onto the wire. You'd just need to
> abstract out the XDR/RPC specific bits."
>
> The idea has been floating around in the back of my head until recently,
> when I decided to give it a go. This patchset represents a first, rough
> draft at a patchset to do this. There's also a proof of concept module
> that demonstrates that it works as expected.
>
> The patchset is still very rough. Reconnect behavior is still very
> "RPC-ish", for instance. There are doubtless other changes that will
> need to be made before I had anything merge-worthy.
>
> At this point, I'm just interested in feedback on the general approach.
> Should I continue to pursue this or is it a non-starter for some
> reason?
>
> The next step here, obviously is to start building a fs on top of it.
> I'd particularly be interested in using this as a foundation of a
> new smb2fs.
>
> I've also got this patchset up on my public git tree:
>
>    http://git.samba.org/?p=jlayton/cifs.git;a=summary
>
> Here are some questions I anticipate on this, and their answers:
>
> ------------------------------------------------------------------------
> Q: Are you insane? Why would you attempt to do this?
>
> A: Maybe...but in the last couple of years, I've spent a substantial
> amount of time working on the CIFS code. Much of that time has been
> spent fixing bugs. Many of those bugs exist in the low-level transport
> code which has been hacked on, kludged around and hand tweaked to
> where it is today. Unfortunately that's made it a very hard to work
> on mess. This drives away potential developers.
>
> CIFS in particular is also designed around synchronous ops, which
> seriously limits throughput. Retrofitting it for asynchronous operation
> will be adding even more kludges. The sunrpc code is already
> fundamentally asynchronous.
> ------------------------------------------------------------------------
> Q: Okay, what's the benefit of hooking it up to sunrpc rather than
> building a new transport layer (or fixing the transport in the other two
> filesystems)?
>
> A: Using sunrpc allows us to share a lot of the rpc scheduler code with
> sunrpc. At a high level, NFS/RPC and SMB aren't really very different.
> Sure, they have different formats, and one is big endian on the wire and
> the other isn't...still there are significant similarities.
>
> We also get access to the great upcall mechanisms that sunrpc has, and
> the possibility to share code like the gssapi upcalls. The sunrpc layer
> has a credential and authentication management framework that we can
> build on to make a truly multiuser CIFS/SMB filesystem.
>
> I've heard it claimed before that Linux's sunrpc layer is
> over-engineered, but in this case that works in our favor...
> ------------------------------------------------------------------------
> Q: can we hook up cifs or smbfs to use this as a transport?
>
> A: Not trivially. CIFS in particular is not designed with each call
> having discrete encode and decode functions. They're sort of mashed
> together. smbfs might be possible...I'm a little less familiar with it,
> but it does have a transport layer that more closely resembles the
> sunrpc one. Still though, it'd take significant work to make that
> happen. I'm not opposed to the idea however.
>
> In the end though, I think we'll probably need to design something new
> to sit on top of this. We will probably be able to borrow code and
> concepts from the other filesystems however.
> ------------------------------------------------------------------------
> Q: could we use this as a transport layer for a smb2fs ?
>
> A: Yes, I think so. This particular prototype is build around SMB1, but
> SMB2 could be supported with only minor modifications. One of the
> reasons for sending this patchset now before I've built a filesystem on
> top of it is because I know that SMB2 work is in progress. I'd like to
> see it based around a more asynchronous transport model, or at least
> built with cleaner layering so that we can eventually bolt on a different
> transport layer if we so choose.
>
> Jeff Layton (9):
>  sunrpc: abstract out encoding function at rpc_clnt level
>  sunrpc: move check for too small reply size into rpc_verify_header
>  sunrpc: abstract our call decoding routine
>  sunrpc: move rpc_xdr_buf_init to clnt.h
>  sunrpc: make call_bind non-static
>  sunrpc: add new SMB transport class for sunrpc
>  sunrpc: add encoding and decoding routines for SMB
>  sunrpc: add Kconfig option for CONFIG_SUNRPC_SMB
>  smbtest: simple module for testing SMB/RPC code
>
>  fs/Makefile                    |    2 +
>  fs/lockd/host.c                |    4 +
>  fs/lockd/mon.c                 |    4 +
>  fs/nfs/client.c                |    4 +
>  fs/nfs/mount_clnt.c            |    4 +
>  fs/nfsd/nfs4callback.c         |    4 +
>  fs/smbtest/Makefile            |    1 +
>  fs/smbtest/smbtest.c           |  204 +++++
>  include/linux/sunrpc/clnt.h    |   24 +-
>  include/linux/sunrpc/smb.h     |   42 +
>  include/linux/sunrpc/xprtsmb.h |   59 ++
>  net/sunrpc/Kconfig             |   11 +
>  net/sunrpc/Makefile            |    1 +
>  net/sunrpc/clnt.c              |   98 ++-
>  net/sunrpc/rpcb_clnt.c         |    8 +
>  net/sunrpc/smb.c               |  120 +++
>  net/sunrpc/sunrpc_syms.c       |    3 +
>  net/sunrpc/xprtsmb.c           | 1723
> ++++++++++++++++++++++++++++++++++++++++
>  18 files changed, 2272 insertions(+), 44 deletions(-)
>  create mode 100644 fs/smbtest/Makefile
>  create mode 100644 fs/smbtest/smbtest.c
>  create mode 100644 include/linux/sunrpc/smb.h
>  create mode 100644 include/linux/sunrpc/xprtsmb.h
>  create mode 100644 net/sunrpc/smb.c
>  create mode 100644 net/sunrpc/xprtsmb.c
>
> _______________________________________________
> linux-cifs-client mailing list
> linux-cifs-client@lists.samba.org
> https://lists.samba.org/mailman/listinfo/linux-cifs-client
>


Jeff,

So servers need to speak SUNRPC as well right?
Are_threre/how_many servers are out there that speak CIFS/SMB over SUNRPC or
SMB2 over SUNRPC?

--001636c925643d092c047499f51c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br>
<div class=3D"gmail_quote">On Sun, Sep 27, 2009 at 11:50 AM, Jeff Layton <s=
pan dir=3D"ltr">&lt;<a href=3D"mailto:jlayton@redhat.com">jlayton@redhat.co=
m</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"PADDING-LEFT: 1ex; MARGIN: 0px 0=
px 0px 0.8ex; BORDER-LEFT: #ccc 1px solid">This patchset is still prelimina=
ry and is just an RFC...<br><br>First, some background. When I was at Conne=
ctathon this year, Trond<br>
mentioned an interesting idea to me. He said (paraphrasing):<br><br>&quot;W=
hy doesn&#39;t CIFS just use the RPC layer for transport? It&#39;s very<br>=
efficient at shoveling bits out onto the wire. You&#39;d just need to<br>
abstract out the XDR/RPC specific bits.&quot;<br><br>The idea has been floa=
ting around in the back of my head until recently,<br>when I decided to giv=
e it a go. This patchset represents a first, rough<br>draft at a patchset t=
o do this. There&#39;s also a proof of concept module<br>
that demonstrates that it works as expected.<br><br>The patchset is still v=
ery rough. Reconnect behavior is still very<br>&quot;RPC-ish&quot;, for ins=
tance. There are doubtless other changes that will<br>need to be made befor=
e I had anything merge-worthy.<br>
<br>At this point, I&#39;m just interested in feedback on the general appro=
ach.<br>Should I continue to pursue this or is it a non-starter for some<br=
>reason?<br><br>The next step here, obviously is to start building a fs on =
top of it.<br>
I&#39;d particularly be interested in using this as a foundation of a<br>ne=
w smb2fs.<br><br>I&#39;ve also got this patchset up on my public git tree:<=
br><br>=A0 =A0<a href=3D"http://git.samba.org/?p=3Djlayton/cifs.git;a=3Dsum=
mary" target=3D"_blank">http://git.samba.org/?p=3Djlayton/cifs.git;a=3Dsumm=
ary</a><br>
<br>Here are some questions I anticipate on this, and their answers:<br><br=
>------------------------------------------------------------------------<b=
r>Q: Are you insane? Why would you attempt to do this?<br><br>A: Maybe...bu=
t in the last couple of years, I&#39;ve spent a substantial<br>
amount of time working on the CIFS code. Much of that time has been<br>spen=
t fixing bugs. Many of those bugs exist in the low-level transport<br>code =
which has been hacked on, kludged around and hand tweaked to<br>where it is=
 today. Unfortunately that&#39;s made it a very hard to work<br>
on mess. This drives away potential developers.<br><br>CIFS in particular i=
s also designed around synchronous ops, which<br>seriously limits throughpu=
t. Retrofitting it for asynchronous operation<br>will be adding even more k=
ludges. The sunrpc code is already<br>
fundamentally asynchronous.<br>--------------------------------------------=
----------------------------<br>Q: Okay, what&#39;s the benefit of hooking =
it up to sunrpc rather than<br>building a new transport layer (or fixing th=
e transport in the other two<br>
filesystems)?<br><br>A: Using sunrpc allows us to share a lot of the rpc sc=
heduler code with<br>sunrpc. At a high level, NFS/RPC and SMB aren&#39;t re=
ally very different.<br>Sure, they have different formats, and one is big e=
ndian on the wire and<br>
the other isn&#39;t...still there are significant similarities.<br><br>We a=
lso get access to the great upcall mechanisms that sunrpc has, and<br>the p=
ossibility to share code like the gssapi upcalls. The sunrpc layer<br>has a=
 credential and authentication management framework that we can<br>
build on to make a truly multiuser CIFS/SMB filesystem.<br><br>I&#39;ve hea=
rd it claimed before that Linux&#39;s sunrpc layer is<br>over-engineered, b=
ut in this case that works in our favor...<br>-----------------------------=
-------------------------------------------<br>
Q: can we hook up cifs or smbfs to use this as a transport?<br><br>A: Not t=
rivially. CIFS in particular is not designed with each call<br>having discr=
ete encode and decode functions. They&#39;re sort of mashed<br>together. sm=
bfs might be possible...I&#39;m a little less familiar with it,<br>
but it does have a transport layer that more closely resembles the<br>sunrp=
c one. Still though, it&#39;d take significant work to make that<br>happen.=
 I&#39;m not opposed to the idea however.<br><br>In the end though, I think=
 we&#39;ll probably need to design something new<br>
to sit on top of this. We will probably be able to borrow code and<br>conce=
pts from the other filesystems however.<br>--------------------------------=
----------------------------------------<br>Q: could we use this as a trans=
port layer for a smb2fs ?<br>
<br>A: Yes, I think so. This particular prototype is build around SMB1, but=
<br>SMB2 could be supported with only minor modifications. One of the<br>re=
asons for sending this patchset now before I&#39;ve built a filesystem on<b=
r>
top of it is because I know that SMB2 work is in progress. I&#39;d like to<=
br>see it based around a more asynchronous transport model, or at least<br>=
built with cleaner layering so that we can eventually bolt on a different<b=
r>
transport layer if we so choose.<br><br>Jeff Layton (9):<br>=A0sunrpc: abst=
ract out encoding function at rpc_clnt level<br>=A0sunrpc: move check for t=
oo small reply size into rpc_verify_header<br>=A0sunrpc: abstract our call =
decoding routine<br>
=A0sunrpc: move rpc_xdr_buf_init to clnt.h<br>=A0sunrpc: make call_bind non=
-static<br>=A0sunrpc: add new SMB transport class for sunrpc<br>=A0sunrpc: =
add encoding and decoding routines for SMB<br>=A0sunrpc: add Kconfig option=
 for CONFIG_SUNRPC_SMB<br>
=A0smbtest: simple module for testing SMB/RPC code<br><br>=A0fs/Makefile =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +<br>=A0fs/lockd/host.c =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +<br>=A0fs/lockd/mon.c =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +<br>=A0fs/nfs/client.c =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0| =A0 =A04 +<br>
=A0fs/nfs/mount_clnt.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +<br>=A0fs/nfsd/nf=
s4callback.c =A0 =A0 =A0 =A0 | =A0 =A04 +<br>=A0fs/smbtest/Makefile =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 =A01 +<br>=A0fs/smbtest/smbtest.c =A0 =A0 =A0 =A0 =A0=
 | =A0204 +++++<br>=A0include/linux/sunrpc/clnt.h =A0 =A0| =A0 24 +-<br>
=A0include/linux/sunrpc/smb.h =A0 =A0 | =A0 42 +<br>=A0include/linux/sunrpc=
/xprtsmb.h | =A0 59 ++<br>=A0net/sunrpc/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 11 +<br>=A0net/sunrpc/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +<br>=
=A0net/sunrpc/clnt.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 98 ++-<br>
=A0net/sunrpc/rpcb_clnt.c =A0 =A0 =A0 =A0 | =A0 =A08 +<br>=A0net/sunrpc/smb=
.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0120 +++<br>=A0net/sunrpc/sunrpc_syms.c =
=A0 =A0 =A0 | =A0 =A03 +<br>=A0net/sunrpc/xprtsmb.c =A0 =A0 =A0 =A0 =A0 | 1=
723 ++++++++++++++++++++++++++++++++++++++++<br>=A018 files changed, 2272 i=
nsertions(+), 44 deletions(-)<br>
=A0create mode 100644 fs/smbtest/Makefile<br>=A0create mode 100644 fs/smbte=
st/smbtest.c<br>=A0create mode 100644 include/linux/sunrpc/smb.h<br>=A0crea=
te mode 100644 include/linux/sunrpc/xprtsmb.h<br>=A0create mode 100644 net/=
sunrpc/smb.c<br>
=A0create mode 100644 net/sunrpc/xprtsmb.c<br><br>_________________________=
______________________<br>linux-cifs-client mailing list<br><a href=3D"mail=
to:linux-cifs-client@lists.samba.org">linux-cifs-client@lists.samba.org</a>=
<br>
<a href=3D"https://lists.samba.org/mailman/listinfo/linux-cifs-client" targ=
et=3D"_blank">https://lists.samba.org/mailman/listinfo/linux-cifs-client</a=
><br></blockquote></div>
<div>=A0</div>
<div>=A0</div>
<div>Jeff,</div>
<div>=A0</div>
<div>So servers need to speak SUNRPC as well right?</div>
<div>Are_threre/how_many servers are out there that speak CIFS/SMB over SUN=
RPC or SMB2 over SUNRPC?</div>
<div>=A0</div>
<div><br>=A0</div>

--001636c925643d092c047499f51c--

--===============3782171883188185071==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-cifs-client mailing list
linux-cifs-client@lists.samba.org
https://lists.samba.org/mailman/listinfo/linux-cifs-client

--===============3782171883188185071==--
