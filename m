From: Frank S Filz <ffilz@us.ibm.com>
Subject: Re: [PATCH v3 7/7] NFSD: Pass share reservations flags to VFS
Date: Mon, 11 Mar 2013 13:25:20 -0700
Message-ID: <OF1D20435B.D7D7B48E-ON87257B2B.006FB8C9-88257B2B.00702F2E@us.ibm.com>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<1362065133-9490-8-git-send-email-piastry@etersoft.ru>
	<20130311150540.119abd63@corrin.poochiereds.net>
	<20130311193638.GB642@fieldses.org>
	<20130311160844.7dedf15a@corrin.poochiereds.net>
	<20130311201108.GE642@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6535880014786133835=="
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>, wine-devel@winehq.org,
	linux-kernel@vger.kernel.org, Pavel Shilovsky <piastry@etersoft.ru>,
	linux-fsdevel@vger.kernel.org, linux-nfs-owner@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <wine-devel-bounces@winehq.org>
In-Reply-To: <20130311201108.GE642@fieldses.org>
List-Unsubscribe: <http://www.winehq.org/mailman/options/wine-devel>,
	<mailto:wine-devel-request@winehq.org?subject=unsubscribe>
List-Archive: <http://www.winehq.org/pipermail/wine-devel>
List-Post: <mailto:wine-devel@winehq.org>
List-Help: <mailto:wine-devel-request@winehq.org?subject=help>
List-Subscribe: <http://www.winehq.org/mailman/listinfo/wine-devel>,
	<mailto:wine-devel-request@winehq.org?subject=subscribe>
Sender: wine-devel-bounces@winehq.org
Errors-To: wine-devel-bounces@winehq.org
List-ID: <linux-nfs.vger.kernel.org>

--===============6535880014786133835==
Content-type: multipart/alternative;
	Boundary="0__=08BBF1B8DFFC3E598f9e8a93df938690918c08BBF1B8DFFC3E59"
Content-Disposition: inline

--0__=08BBF1B8DFFC3E598f9e8a93df938690918c08BBF1B8DFFC3E59
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable


"J. Bruce Fields" <bfields@fieldses.org>  wrote
> On Mon, Mar 11, 2013 at 04:08:44PM -0400, Jeff Layton wrote:
> > On Mon, 11 Mar 2013 15:36:38 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > It doesn't look like this patch removes any of that old code
though. I
> > > > think it probably should, or there ought to be some considerati=
on
of
> > > > how this new stuff will mesh with it.
> > > >
> > > > I think you have 2 choices here:
> > > >
> > > > 1/ rip out the old share reservation code altogether and requir=
e
that
> > > > filesystems mount with -o sharemand or whatever if they want to=

allow
> > > > their enforcement
> > > >
> > > > 2/ make knfsd fall back to using the internal share reservation=

code
> > > > when the mount option isn't enabled
> > > >
> > > > Personally, I think #1 would be fine, but Bruce may want to wei=
gh
in on
> > > > what he'd prefer.
> > >
> > > #1 sounds good.  Clients that use deny bits are few.  My preferen=
ce
> > > would be to return an error to such clients in the case share loc=
ks
> > > aren't available.
> > >
> > > (We're a little out of spec there, so I'm not sure which error.  =
I
think
> > > the goal is to notify a human there's a problem with minimal
collateral
> > > damange.
> > >
> > > NFS4ERR_SERVERFAULT ("I'm a buggy server, sorry about that!") wou=
ld
> > > probably result in an IO error to the application.
> > >
> > > SHARE_DENIED strikes me as unsafe: an application would be in its=

rights
> > > not to even check for that e.g. in the case of an exclusive creat=
e.

Hmm, shouldn't the client catch that with a "default" case at least?

> > > Maybe DELAY?  Kind of ridiculous, but blocking the application
> > > indefinitely would probably get someone's attention quickly enoug=
h
> > > without doing any damnage.)
> > >
> >
> > I agree that we should return an error, but hadn't considered what
> > error. Given that hardly any NFS clients use them, I'd probably jus=
t go
> > with NFS4ERR_SERVERFAULT, and maybe throw a printk or something on =
the
> > server about enabling share reservations for superblock x:y.
>
> Sounds reasonable.

If I'm understanding, the suggestion is a mount option to enable share
reservations and if so, they will be mandatory?

In that case, perhaps we want to keep the existing knfsd code as a
fallback, someone might want to support them, but not have them be
mandatory (if nothing else, you may cause consternation from folks runn=
ing
pynfs against a default configured knfsd server....).

In the Ganesha project, we provide an internal implementation of share
reservations for when the underlying system can not support them.

Another bit to consider, does lockd provide share reservations for NLM?=


Frank=

--0__=08BBF1B8DFFC3E598f9e8a93df938690918c08BBF1B8DFFC3E59
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p><tt><font size=3D"2">&quot;J. Bruce Fields&quot; &lt;bfields@fieldse=
s.org&gt; &nbsp;wrote</font></tt><br>
<tt><font size=3D"2">&gt; On Mon, Mar 11, 2013 at 04:08:44PM -0400, Jef=
f Layton wrote:<br>
&gt; &gt; On Mon, 11 Mar 2013 15:36:38 -0400<br>
&gt; &gt; &quot;J. Bruce Fields&quot; &lt;bfields@fieldses.org&gt; wrot=
e:<br>
&gt; &gt; &gt; &gt; It doesn't look like this patch removes any of that=
 old code though. I<br>
&gt; &gt; &gt; &gt; think it probably should, or there ought to be some=
 consideration of<br>
&gt; &gt; &gt; &gt; how this new stuff will mesh with it.<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; I think you have 2 choices here:<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; 1/ rip out the old share reservation code altogethe=
r and require that<br>
&gt; &gt; &gt; &gt; filesystems mount with -o sharemand or whatever if =
they want to allow<br>
&gt; &gt; &gt; &gt; their enforcement<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; 2/ make knfsd fall back to using the internal share=
 reservation code<br>
&gt; &gt; &gt; &gt; when the mount option isn't enabled<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; Personally, I think #1 would be fine, but Bruce may=
 want to weigh in on<br>
&gt; &gt; &gt; &gt; what he'd prefer.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; #1 sounds good. &nbsp;Clients that use deny bits are few=
. &nbsp;My preference<br>
&gt; &gt; &gt; would be to return an error to such clients in the case =
share locks<br>
&gt; &gt; &gt; aren't available.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; (We're a little out of spec there, so I'm not sure which=
 error. &nbsp;I think<br>
&gt; &gt; &gt; the goal is to notify a human there's a problem with min=
imal collateral<br>
&gt; &gt; &gt; damange.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; NFS4ERR_SERVERFAULT (&quot;I'm a buggy server, sorry abo=
ut that!&quot;) would<br>
&gt; &gt; &gt; probably result in an IO error to the application.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; SHARE_DENIED strikes me as unsafe: an application would =
be in its rights<br>
&gt; &gt; &gt; not to even check for that e.g. in the case of an exclus=
ive create.<br>
</font></tt><br>
<tt><font size=3D"2">Hmm, shouldn't the client catch that with a &quot;=
default&quot; case at least?<br>
</font></tt><br>
<tt><font size=3D"2">&gt; &gt; &gt; Maybe DELAY? &nbsp;Kind of ridiculo=
us, but blocking the application<br>
&gt; &gt; &gt; indefinitely would probably get someone's attention quic=
kly enough<br>
&gt; &gt; &gt; without doing any damnage.)<br>
&gt; &gt; &gt; <br>
&gt; &gt; <br>
&gt; &gt; I agree that we should return an error, but hadn't considered=
 what<br>
&gt; &gt; error. Given that hardly any NFS clients use them, I'd probab=
ly just go<br>
&gt; &gt; with NFS4ERR_SERVERFAULT, and maybe throw a printk or somethi=
ng on the<br>
&gt; &gt; server about enabling share reservations for superblock x:y.<=
br>
&gt; <br>
&gt; Sounds reasonable.<br>
</font></tt><br>
<tt><font size=3D"2">If I'm understanding, the suggestion is a mount op=
tion to enable share reservations and if so, they will be mandatory?</f=
ont></tt><br>
<br>
<tt><font size=3D"2">In that case, perhaps we want to keep the existing=
 knfsd code as a fallback, someone might want to support them, but not =
have them be mandatory (if nothing else, you may cause consternation fr=
om folks running pynfs against a default configured knfsd server....).<=
/font></tt><br>
<br>
<tt><font size=3D"2">In the Ganesha project, we provide an internal imp=
lementation of share reservations for when the underlying system can no=
t support them.</font></tt><br>
<br>
<tt><font size=3D"2">Another bit to consider, does lockd provide share =
reservations for NLM?</font></tt><br>
<br>
<tt><font size=3D"2">Frank</font></tt><br>
</body></html>=

--0__=08BBF1B8DFFC3E598f9e8a93df938690918c08BBF1B8DFFC3E59--



--===============6535880014786133835==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



--===============6535880014786133835==--
