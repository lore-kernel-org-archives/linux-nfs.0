From: Anand Avati <anand.avati@gmail.com>
Subject: Re: regressions due to 64-bit ext4 directory cookies
Date: Wed, 13 Feb 2013 13:21:06 -0800
Message-ID: <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
References: <20130212202841.GC10267@fieldses.org>
	<20130213040003.GB2614@thunk.org>
	<20130213133131.GE14195@fieldses.org>
	<20130213151455.GB17431@thunk.org>
	<20130213151953.GJ14195@fieldses.org>
	<20130213153654.GC17431@thunk.org>
	<20130213162059.GL14195@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4012185096603444397=="
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>,
	Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
	linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org>
In-Reply-To: <20130213162059.GL14195@fieldses.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/gluster-devel>,
	<mailto:gluster-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/gluster-devel>
List-Post: <mailto:gluster-devel@nongnu.org>
List-Help: <mailto:gluster-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/gluster-devel>,
	<mailto:gluster-devel-request@nongnu.org?subject=subscribe>
Errors-To: gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org
Sender: gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org
List-ID: <linux-nfs.vger.kernel.org>

--===============4012185096603444397==
Content-Type: multipart/alternative; boundary=e89a8f92407862fd1004d5a1b8de

--e89a8f92407862fd1004d5a1b8de
Content-Type: text/plain; charset=ISO-8859-1

>
> My understanding is that only one frontend server is running the server.
> So in your picture below, "NFS v3" should be some internal gluster
> protocol:
>
>
>                                                    /------ GFS Storage
>                                                   /        Server #1
>    GFS Cluster     NFS V3      GFS Cluster      -- gluster protocol
>    Client        <--------->   Frontend Server  ---------- GFS Storage
>                                                 --         Server #2
>                                                   \
>                                                    \------ GFS Storage
>                                                            Server #3
>
>
> That frontend server gets a readdir request for a directory which is
> stored across several of the storage servers.  It has to return a
> cookie.  It will get that cookie back from the client at some unknown
> later time (possibly after the server has rebooted).  So their solution
> is to return a cookie from one of the storage servers, plus some kind of
> node id in the top bits so they can remember which server it came from.
>
> (I don't know much about gluster, but I think that's the basic idea.)
>
> I've assumed that users of directory cookies should treat them as
> opaque, so I don't think what gluster is doing is correct.


NFS uses the term cookies, while man pages of readdir/seekdir/telldir calls
them "offsets". RFC 1813 only talks about communication between and NFS
server and NFS client. While knfsd performs a trivial 1:1 mapping between
d_off "offsets" into these "opaque cookies", the "gluster" issue at hand is
that, it made assumptions about the nature of these "offsets" (that they
are representing some kind of true distance/offset and therefore fall
within some kind of bounded magnitude -- somewhat like the inode
numbering), and performs a transformation (instead of a 1:1 trivial
mapping) like this:

  final_d_off = (ext4_d_off * MAX_SERVERS) + server_idx

thereby utilizing a few more top bits, also ability to perform a reverse
transformation to "continue" from a previous location.  As you can see,
final_d_off now overflows for very large values of ext4_d_off. This
final_d_off is used both as cookies in gluster-NFS (userspace) server, and
also as d_off entry parameter in FUSE readdir reply. The gluster / ext4
d_off issue is not limited to gluster-NFS, but also exists in the FUSE
client where NFS is completely out of picture.

You are probably right in that gluster has made different assumptions about
the "nature" of values filled in d_off fields. But the language used in all
man pages makes you believe they were supposed to be numbers representing
some kind of distance/offset (with bounded magnitude), and not a "random"
number.

This had worked (accidentally, you may call it) on all filesystems
including ext4, as expected. But on kernel upgrade, only ext4 backed
deployments started giving problems and we have been advising our users to
either downgrade their kernel or use a different filesystem (we really do
not want to force them into making a choice of one backend filesystem vs
another.)

You can always say "this is your fault" for interpreting the man pages
differently and punish us by leaving things as they are (and unfortunately
a big chunk of users who want both ext4 and gluster jeapordized). Or you
can be kind, generous and be considerate to the legacy apps and users (of
which gluster is only a subset) and only provide a mount option to control
the large d_off behavior.

Thanks!
Avati

--e89a8f92407862fd1004d5a1b8de
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div cla=
ss=3D"im"><br>
<br>
</div>My understanding is that only one frontend server is running the serv=
er.<br>
So in your picture below, &quot;NFS v3&quot; should be some internal gluste=
r<br>
protocol:<br>
<div class=3D"im"><br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0/------ GFS Storage<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 / =A0 =A0 =A0 =A0Server #1<br>
</div>=A0 =A0GFS Cluster =A0 =A0 NFS V3 =A0 =A0 =A0GFS Cluster =A0 =A0 =A0-=
- gluster protocol<br>
<div class=3D"im">=A0 =A0Client =A0 =A0 =A0 =A0&lt;---------&gt; =A0 Fronte=
nd Server =A0---------- GFS Storage<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 -- =A0 =A0 =A0 =A0 Server #2<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 \<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0\------ GFS Storage<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Server #3<br>
<br>
<br>
</div>That frontend server gets a readdir request for a directory which is<=
br>
stored across several of the storage servers. =A0It has to return a<br>
cookie. =A0It will get that cookie back from the client at some unknown<br>
later time (possibly after the server has rebooted). =A0So their solution<b=
r>
is to return a cookie from one of the storage servers, plus some kind of<br=
>
node id in the top bits so they can remember which server it came from.<br>
<br>
(I don&#39;t know much about gluster, but I think that&#39;s the basic idea=
.)<br>
<br>
I&#39;ve assumed that users of directory cookies should treat them as<br>
opaque, so I don&#39;t think what gluster is doing is correct.</blockquote>=
<div><br></div><div>NFS uses the term cookies, while man pages of readdir/s=
eekdir/telldir calls them &quot;offsets&quot;. RFC 1813 only talks about co=
mmunication between and NFS server and NFS client. While knfsd performs a t=
rivial 1:1 mapping between d_off &quot;offsets&quot; into these &quot;opaqu=
e cookies&quot;, the &quot;gluster&quot; issue at hand is that, it made ass=
umptions about the nature of these &quot;offsets&quot; (that they are repre=
senting some kind of true distance/offset and therefore fall within some ki=
nd of bounded magnitude -- somewhat like the inode numbering), and performs=
 a transformation (instead of a 1:1 trivial mapping) like this:</div>
<div><br></div><div>=A0 final_d_off =3D (ext4_d_off * MAX_SERVERS) + server=
_idx</div><div><br></div><div>thereby utilizing a few more top bits, also a=
bility to perform a reverse transformation to &quot;continue&quot; from a p=
revious location. =A0As you can see, final_d_off now overflows for very lar=
ge values of ext4_d_off.=A0This final_d_off is used both as cookies in glus=
ter-NFS (userspace) server, and also as d_off entry parameter in FUSE readd=
ir reply. The gluster / ext4 d_off issue is not limited to gluster-NFS, but=
 also exists in the FUSE client where NFS is completely out of picture.</di=
v>
<div><br></div><div>You are probably right in that gluster has made differe=
nt assumptions about the &quot;nature&quot; of values filled in d_off field=
s. But the language used in all man pages makes you believe they were suppo=
sed to be numbers representing some kind of distance/offset (with bounded m=
agnitude), and not a &quot;random&quot; number.</div>
<div><br></div><div>This had worked (accidentally, you may call it) on all =
filesystems including ext4, as expected. But on kernel upgrade, only ext4 b=
acked deployments started giving problems and we have been advising our use=
rs to either downgrade their kernel or use a different filesystem (we reall=
y do not want to force them into making a choice of one backend filesystem =
vs another.)</div>
<div><br></div><div>You can always say &quot;this is your fault&quot; for i=
nterpreting the man pages differently and punish us by leaving things as th=
ey are (and unfortunately a big chunk of users who want both ext4 and glust=
er jeapordized). Or you can be kind, generous and be considerate to the leg=
acy apps and users (of which gluster is only a subset) and only provide a m=
ount option to control the large d_off behavior.</div>
<div><br></div><div>Thanks!</div><div>Avati</div><div><br></div></div>

--e89a8f92407862fd1004d5a1b8de--


--===============4012185096603444397==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Gluster-devel mailing list
Gluster-devel@nongnu.org
https://lists.nongnu.org/mailman/listinfo/gluster-devel

--===============4012185096603444397==--
