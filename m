From: Anand Avati <anand.avati@gmail.com>
Subject: Re: regressions due to 64-bit ext4 directory cookies
Date: Wed, 13 Feb 2013 14:57:13 -0800
Message-ID: <CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com>
References: <20130212202841.GC10267@fieldses.org>
	<20130213040003.GB2614@thunk.org>
	<20130213133131.GE14195@fieldses.org>
	<20130213151455.GB17431@thunk.org>
	<20130213151953.GJ14195@fieldses.org>
	<20130213153654.GC17431@thunk.org>
	<20130213162059.GL14195@fieldses.org>
	<CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
	<20130213222052.GD5938@thunk.org>
	<20130213224141.GU14195@fieldses.org>
	<20130213224720.GE5938@thunk.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2090807389247122098=="
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
	linux-nfs@vger.kernel.org, sandeen@redhat.com,
	linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
To: "Theodore Ts'o" <tytso@mit.edu>
Return-path: <gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org>
In-Reply-To: <20130213224720.GE5938-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
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

--===============2090807389247122098==
Content-Type: multipart/alternative; boundary=e89a8ff1c25423557804d5a31030

--e89a8ff1c25423557804d5a31030
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Feb 13, 2013 at 2:47 PM, Theodore Ts'o <tytso@mit.edu> wrote:

> On Wed, Feb 13, 2013 at 05:41:41PM -0500, J. Bruce Fields wrote:
> > > What if we have an ioctl or a process personality flag where a broken
> > > application can tell the file system "I'm broken, please give me a
> > > degraded telldir/seekdir cookie"?  That way we don't penalize programs
> > > that are doing the right thing, while providing some accomodation for
> > > programs who are abusing the telldir cookie.
> >
> > Yeah, if there's a simple way to do that, maybe it would be worth it.
>
> Doing this as an ioctl which gets called right after opendir, i.e
> (ignoring error checking):
>
>       DIR *dir = opendir("/foo/bar/baz");
>       ioctl(dirfd(dir), EXT4_IOC_DEGRADED_READDIR, 1);
>       ...
>
> should be quite easy.  It would be a very ext3/4 specific thing,
> though.


That would work, even though it would be ext3/4 specific. What is the
recommended programmatic way to detect if the file is on ext3/4 -- we would
not want to attempt that blindly on a non-ext3/4 FS as the numerical value
of EXT4_IOC_DEGRADED_READDIR might get interpreted in dangerous ways?

Avati

--e89a8ff1c25423557804d5a31030
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Feb 13, 2013 at 2:47 PM, Theodor=
e Ts&#39;o <span dir=3D"ltr">&lt;<a href=3D"mailto:tytso@mit.edu" target=3D=
"_blank">tytso@mit.edu</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">
<div class=3D"im">On Wed, Feb 13, 2013 at 05:41:41PM -0500, J. Bruce Fields=
 wrote:<br>
&gt; &gt; What if we have an ioctl or a process personality flag where a br=
oken<br>
&gt; &gt; application can tell the file system &quot;I&#39;m broken, please=
 give me a<br>
&gt; &gt; degraded telldir/seekdir cookie&quot;? =A0That way we don&#39;t p=
enalize programs<br>
&gt; &gt; that are doing the right thing, while providing some accomodation=
 for<br>
&gt; &gt; programs who are abusing the telldir cookie.<br>
&gt;<br>
&gt; Yeah, if there&#39;s a simple way to do that, maybe it would be worth =
it.<br>
<br>
</div>Doing this as an ioctl which gets called right after opendir, i.e<br>
(ignoring error checking):<br>
<br>
=A0 =A0 =A0 DIR *dir =3D opendir(&quot;/foo/bar/baz&quot;);<br>
=A0 =A0 =A0 ioctl(dirfd(dir), EXT4_IOC_DEGRADED_READDIR, 1);<br>
=A0 =A0 =A0 ...<br>
<br>
should be quite easy. =A0It would be a very ext3/4 specific thing,<br>
though.</blockquote><div><br></div><div>That would work, even though it wou=
ld be ext3/4 specific. What is the recommended programmatic way to detect i=
f the file is on ext3/4 -- we would not want to attempt that blindly on a n=
on-ext3/4 FS as the numerical value of=A0EXT4_IOC_DEGRADED_READDIR might ge=
t interpreted in dangerous ways?</div>
<div><br></div><div>Avati</div></div>

--e89a8ff1c25423557804d5a31030--


--===============2090807389247122098==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Gluster-devel mailing list
Gluster-devel@nongnu.org
https://lists.nongnu.org/mailman/listinfo/gluster-devel

--===============2090807389247122098==--
