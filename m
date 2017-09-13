Return-Path: nfsv4-bounces@ietf.org
In-Reply-To: <20170913162111.GA14389@infradead.org>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <20170913162111.GA14389@infradead.org>
From: David Noveck <davenoveck@gmail.com>
Date: Wed, 13 Sep 2017 14:18:09 -0400
Message-ID: <CADaq8jd2VaHUX=9rVbG41tTPj+9R8Grkjnaoh1hfKv8sVn5-GA@mail.gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Subject: Re: [nfsv4] [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
List-Unsubscribe: <https://www.ietf.org/mailman/options/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <https://mailarchive.ietf.org/arch/browse/nfsv4/>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=subscribe>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        Steve Dickson <steved@redhat.com>, "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "J . Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Matt Benjamin <mbenjami@redhat.com>
Content-Type: multipart/mixed; boundary="===============2096427446142758556=="
Errors-To: nfsv4-bounces@ietf.org
Sender: "nfsv4" <nfsv4-bounces@ietf.org>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============2096427446142758556==
Content-Type: multipart/alternative; boundary="001a114052dcac647b0559162e35"

--001a114052dcac647b0559162e35
Content-Type: text/plain; charset="UTF-8"

> and how to ask IESG to assign it?

The way to get the IESG to assign it would be to write an RFC and get it
approved as a Proposed Standard but I don't think you need to do that.
There is a portion of the netid registry that is assigned on a
first-come-first-served basis (see RFCs 5665 and 5226) and if you are OK
with that, the IESG doesn't have to be involved.  You simply have to ask
IANA to assign it, providing the information (pretty limited) mentioned in
those RFCs.

On Wed, Sep 13, 2017 at 12:21 PM, Christoph Hellwig <hch@infradead.org>
wrote:

> Please get your VSOCK NFS transport into the ietf NFSv4 working group
> first before moving forward with Linux support - we should not implement
> non-standardized extensions.
>
> On Wed, Sep 13, 2017 at 11:26:36AM +0100, Stefan Hajnoczi wrote:
> >  * The last revision was somewhat controversial because it's already
> possible
> >    to share files between a hypervisor and virtual machine using TCP/IP,
> so why
> >    add AF_VSOCK support to the stack?  TCP/IP based solutions require the
> >    virtual machine administrator to be involved in the configuration and
> are
> >    therefore not suitable for automatic management by OpenStack, oVirt,
> etc.
> >    Maintainers, is this feature acceptable?
> >
> >  * Need advice on netid: is there agreement to use "tcpv" instead of
> "vsock" as
> >    Chuck Lever suggested and how to ask IESG to assign it?
> >
> > The AF_VSOCK address family allows virtual machines to communicate with
> the
> > hypervisor using a zero-configuration transport.  KVM, VMware, and
> Hyper-V
> > hypervisors support AF_VSOCK and it was first introduced in Linux 3.9.
> >
> > This patch series adds AF_VSOCK support to mount.nfs(8) and
> rpc.nfsd(8).  To
> > mount an export from the hypervisor (CID 2):
> >
> >   # mount.nfs 2:/srv/vm01 /mnt -o proto=vsock
> >
> > To serve exports over vsock port 2049:
> >
> >   # nfsd ... --vsock 2049
> >
> > This series extends exports(5) syntax to handle vsock:<CID> or vsock:*.
> For
> > example, the guest with CID 3 can be given access using vsock:3.
> >
> > nfsd can export over IPv4/IPv6 and vsock at the same time.  See the
> changes to
> > exports.man, nfs.man, and nfsd.man in the patches for syntax details.
> >
> > NFSv4 and later are supported.
> >
> > The code is also available here:
> > https://github.com/stefanha/nfs-utils/tree/vsock-nfsd
> >
> > The latest kernel patches are available here:
> > https://github.com/stefanha/linux/tree/vsock-nfsd
> >
> > Stefan Hajnoczi (14):
> >   mount: don't use IPPROTO_UDP for address resolution
> >   nfs-utils: add vsock.h
> >   nfs-utils: add AF_VSOCK support to sockaddr.h
> >   mount: present AF_VSOCK addresses
> >   mount: accept AF_VSOCK in nfs_verify_family()
> >   mount: generate AF_VSOCK clientaddr
> >   getport: recognize "vsock" netid
> >   mount: AF_VSOCK address parsing
> >   exportfs: introduce host_freeaddrinfo()
> >   exportfs: add AF_VSOCK address parsing and printing
> >   exportfs: add AF_VSOCK support to set_addrlist()
> >   exportfs: add support for "vsock:" exports(5) syntax
> >   nfsd: add --vsock (-v) option to nfsd
> >   tests: add "vsock:" exports(5) test case
> >
> >  tests/Makefile.am          |   3 +-
> >  support/include/exportfs.h |   4 ++
> >  support/include/sockaddr.h |  18 +++++
> >  support/include/vsock.h    |  59 +++++++++++++++++
> >  utils/nfsd/nfssvc.h        |   1 +
> >  support/export/client.c    |   8 +--
> >  support/export/hostname.c  | 161 ++++++++++++++++++++++++++++++
> +++++++++++++--
> >  support/nfs/getport.c      |  16 +++--
> >  utils/exportfs/exportfs.c  |  42 ++++++++++--
> >  utils/mount/network.c      |  37 ++++++++++-
> >  utils/mount/stropts.c      |  61 ++++++++++++++---
> >  utils/mountd/auth.c        |   2 +-
> >  utils/mountd/cache.c       |  10 +--
> >  utils/mountd/mountd.c      |   4 +-
> >  utils/mountd/rmtab.c       |   2 +-
> >  utils/nfsd/nfsd.c          |  18 ++++-
> >  utils/nfsd/nfssvc.c        |  62 +++++++++++++++++
> >  configure.ac               |   3 +
> >  tests/t0002-vsock-basic.sh |  53 +++++++++++++++
> >  utils/exportfs/exports.man |  12 +++-
> >  utils/mount/nfs.man        |  20 ++++--
> >  utils/nfsd/nfsd.man        |   4 ++
> >  22 files changed, 552 insertions(+), 48 deletions(-)
> >  create mode 100644 support/include/vsock.h
> >  create mode 100755 tests/t0002-vsock-basic.sh
> >
> > --
> > 2.13.5
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> ---end quoted text---
>
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
>

--001a114052dcac647b0559162e35
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf-8"><d=
iv dir=3D"ltr"><span style=3D"font-size:12.8px">&gt; and how to ask IESG to=
 assign it?</span><br><div><span style=3D"font-size:12.8px"><br></span></di=
v><div><span style=3D"font-size:12.8px">The way to get the IESG to assign i=
t would be to write an RFC and get it approved as a Proposed Standard but I=
 don't think you need to do that.&nbsp; There is a portion of the netid reg=
istry that is assigned on a first-come-first-served basis (see RFCs 5665 an=
d 5226) and if you are OK with that, the IESG doesn't have to be involved.&=
nbsp; You simply have to ask IANA to assign it, providing the information (=
pretty limited) mentioned in those RFCs.</span></div></div><div class=3D"gm=
ail_extra"><br><div class=3D"gmail_quote">On Wed, Sep 13, 2017 at 12:21 PM,=
 Christoph Hellwig <span dir=3D"ltr">&lt;<a href=3D"mailto:hch@infradead.or=
g" target=3D"_blank">hch@infradead.org</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">Please get your VSOCK NFS transport into the ietf NFSv4=
 working group<br>
first before moving forward with Linux support - we should not implement<br=
>
non-standardized extensions.<br>
<br>
On Wed, Sep 13, 2017 at 11:26:36AM &#43;0100, Stefan Hajnoczi wrote:<br>
&gt;&nbsp; * The last revision was somewhat controversial because it's alre=
ady possible<br>
&gt;&nbsp; &nbsp; to share files between a hypervisor and virtual machine u=
sing TCP/IP, so why<br>
&gt;&nbsp; &nbsp; add AF_VSOCK support to the stack?&nbsp; TCP/IP based sol=
utions require the<br>
&gt;&nbsp; &nbsp; virtual machine administrator to be involved in the confi=
guration and are<br>
&gt;&nbsp; &nbsp; therefore not suitable for automatic management by OpenSt=
ack, oVirt, etc.<br>
&gt;&nbsp; &nbsp; Maintainers, is this feature acceptable?<br>
&gt;<br>
&gt;&nbsp; * Need advice on netid: is there agreement to use &quot;tcpv&quo=
t; instead of &quot;vsock&quot; as<br>
&gt;&nbsp; &nbsp; Chuck Lever suggested and how to ask IESG to assign it?<b=
r>
&gt;<br>
&gt; The AF_VSOCK address family allows virtual machines to communicate wit=
h the<br>
&gt; hypervisor using a zero-configuration transport.&nbsp; KVM, VMware, an=
d Hyper-V<br>
&gt; hypervisors support AF_VSOCK and it was first introduced in Linux 3.9.=
<br>
&gt;<br>
&gt; This patch series adds AF_VSOCK support to mount.nfs(8) and rpc.nfsd(8=
).&nbsp; To<br>
&gt; mount an export from the hypervisor (CID 2):<br>
&gt;<br>
&gt;&nbsp; &nbsp;# mount.nfs 2:/srv/vm01 /mnt -o proto=3Dvsock<br>
&gt;<br>
&gt; To serve exports over vsock port 2049:<br>
&gt;<br>
&gt;&nbsp; &nbsp;# nfsd ... --vsock 2049<br>
&gt;<br>
&gt; This series extends exports(5) syntax to handle vsock:&lt;CID&gt; or v=
sock:*.&nbsp; For<br>
&gt; example, the guest with CID 3 can be given access using vsock:3.<br>
&gt;<br>
&gt; nfsd can export over IPv4/IPv6 and vsock at the same time.&nbsp; See t=
he changes to<br>
&gt; exports.man, nfs.man, and nfsd.man in the patches for syntax details.<=
br>
&gt;<br>
&gt; NFSv4 and later are supported.<br>
&gt;<br>
&gt; The code is also available here:<br>
&gt; <a href=3D"https://github.com/stefanha/nfs-utils/tree/vsock-nfsd" rel=
=3D"noreferrer" target=3D"_blank">https://github.com/stefanha/<wbr>nfs-util=
s/tree/vsock-nfsd</a><br>
&gt;<br>
&gt; The latest kernel patches are available here:<br>
&gt; <a href=3D"https://github.com/stefanha/linux/tree/vsock-nfsd" rel=3D"n=
oreferrer" target=3D"_blank">https://github.com/stefanha/<wbr>linux/tree/vs=
ock-nfsd</a><br>
&gt;<br>
&gt; Stefan Hajnoczi (14):<br>
&gt;&nbsp; &nbsp;mount: don't use IPPROTO_UDP for address resolution<br>
&gt;&nbsp; &nbsp;nfs-utils: add vsock.h<br>
&gt;&nbsp; &nbsp;nfs-utils: add AF_VSOCK support to sockaddr.h<br>
&gt;&nbsp; &nbsp;mount: present AF_VSOCK addresses<br>
&gt;&nbsp; &nbsp;mount: accept AF_VSOCK in nfs_verify_family()<br>
&gt;&nbsp; &nbsp;mount: generate AF_VSOCK clientaddr<br>
&gt;&nbsp; &nbsp;getport: recognize &quot;vsock&quot; netid<br>
&gt;&nbsp; &nbsp;mount: AF_VSOCK address parsing<br>
&gt;&nbsp; &nbsp;exportfs: introduce host_freeaddrinfo()<br>
&gt;&nbsp; &nbsp;exportfs: add AF_VSOCK address parsing and printing<br>
&gt;&nbsp; &nbsp;exportfs: add AF_VSOCK support to set_addrlist()<br>
&gt;&nbsp; &nbsp;exportfs: add support for &quot;vsock:&quot; exports(5) sy=
ntax<br>
&gt;&nbsp; &nbsp;nfsd: add --vsock (-v) option to nfsd<br>
&gt;&nbsp; &nbsp;tests: add &quot;vsock:&quot; exports(5) test case<br>
&gt;<br>
&gt;&nbsp; tests/Makefile.am&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; |&nbsp; &nbs=
p;3 &#43;-<br>
&gt;&nbsp; support/include/exportfs.h |&nbsp; &nbsp;4 &#43;&#43;<br>
&gt;&nbsp; support/include/sockaddr.h |&nbsp; 18 &#43;&#43;&#43;&#43;&#43;<=
br>
&gt;&nbsp; support/include/vsock.h&nbsp; &nbsp; |&nbsp; 59 &#43;&#43;&#43;&=
#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;<br>
&gt;&nbsp; utils/nfsd/nfssvc.h&nbsp; &nbsp; &nbsp; &nbsp; |&nbsp; &nbsp;1 &=
#43;<br>
&gt;&nbsp; support/export/client.c&nbsp; &nbsp; |&nbsp; &nbsp;8 &#43;--<br>
&gt;&nbsp; support/export/hostname.c&nbsp; | 161 &#43;&#43;&#43;&#43;&#43;&=
#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&=
#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;<wbr>&#43;&#43;&#43;&#43;&=
#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;--<br>
&gt;&nbsp; support/nfs/getport.c&nbsp; &nbsp; &nbsp; |&nbsp; 16 &#43;&#43;&=
#43;--<br>
&gt;&nbsp; utils/exportfs/exportfs.c&nbsp; |&nbsp; 42 &#43;&#43;&#43;&#43;&=
#43;&#43;&#43;&#43;&#43;&#43;--<br>
&gt;&nbsp; utils/mount/network.c&nbsp; &nbsp; &nbsp; |&nbsp; 37 &#43;&#43;&=
#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;-<br>
&gt;&nbsp; utils/mount/stropts.c&nbsp; &nbsp; &nbsp; |&nbsp; 61 &#43;&#43;&=
#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;---<br>
&gt;&nbsp; utils/mountd/auth.c&nbsp; &nbsp; &nbsp; &nbsp; |&nbsp; &nbsp;2 &=
#43;-<br>
&gt;&nbsp; utils/mountd/cache.c&nbsp; &nbsp; &nbsp; &nbsp;|&nbsp; 10 &#43;-=
-<br>
&gt;&nbsp; utils/mountd/mountd.c&nbsp; &nbsp; &nbsp; |&nbsp; &nbsp;4 &#43;-=
<br>
&gt;&nbsp; utils/mountd/rmtab.c&nbsp; &nbsp; &nbsp; &nbsp;|&nbsp; &nbsp;2 &=
#43;-<br>
&gt;&nbsp; utils/nfsd/nfsd.c&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; |&nbsp; 18 &=
#43;&#43;&#43;&#43;-<br>
&gt;&nbsp; utils/nfsd/nfssvc.c&nbsp; &nbsp; &nbsp; &nbsp; |&nbsp; 62 &#43;&=
#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&=
#43;<br>
&gt;&nbsp; <a href=3D"http://configure.ac" rel=3D"noreferrer" target=3D"_bl=
ank">configure.ac</a>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
;|&nbsp; &nbsp;3 &#43;<br>
&gt;&nbsp; tests/t0002-vsock-basic.sh |&nbsp; 53 &#43;&#43;&#43;&#43;&#43;&=
#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;<br>
&gt;&nbsp; utils/exportfs/exports.man |&nbsp; 12 &#43;&#43;&#43;-<br>
&gt;&nbsp; utils/mount/nfs.man&nbsp; &nbsp; &nbsp; &nbsp; |&nbsp; 20 &#43;&=
#43;&#43;&#43;--<br>
&gt;&nbsp; utils/nfsd/nfsd.man&nbsp; &nbsp; &nbsp; &nbsp; |&nbsp; &nbsp;4 &=
#43;&#43;<br>
&gt;&nbsp; 22 files changed, 552 insertions(&#43;), 48 deletions(-)<br>
&gt;&nbsp; create mode 100644 support/include/vsock.h<br>
&gt;&nbsp; create mode 100755 tests/t0002-vsock-basic.sh<br>
&gt;<br>
&gt; --<br>
&gt; 2.13.5<br>
&gt;<br>
&gt; --<br>
&gt; To unsubscribe from this list: send the line &quot;unsubscribe linux-n=
fs&quot; in<br>
&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">=
majordomo@vger.kernel.org</a><br>
&gt; More majordomo info at&nbsp; <a href=3D"http://vger.kernel.org/majordo=
mo-info.html" rel=3D"noreferrer" target=3D"_blank">http://vger.kernel.org/<=
wbr>majordomo-info.html</a><br>
---end quoted text---<br>
<br>
______________________________<wbr>_________________<br>
nfsv4 mailing list<br>
<a href=3D"mailto:nfsv4@ietf.org">nfsv4@ietf.org</a><br>
<a href=3D"https://www.ietf.org/mailman/listinfo/nfsv4" rel=3D"noreferrer" =
target=3D"_blank">https://www.ietf.org/mailman/<wbr>listinfo/nfsv4</a><br>
</blockquote></div><br></div>

--001a114052dcac647b0559162e35--

--===============2096427446142758556==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============2096427446142758556==--
