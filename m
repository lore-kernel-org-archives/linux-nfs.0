Return-Path: <pconstantine@gmail.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1510011325260.5275@planck.local>
References: <CAOEg9Lo4N3ceJYV0=L-Khrh-oTFZUyTTS=X5acXTg9JKfe2_YA@mail.gmail.com>
	<alpine.OSX.2.19.9992.1510011325260.5275@planck.local>
Date: Thu, 1 Oct 2015 12:37:31 -0500
Message-ID: <CAOEg9Lr2rcAUC_x0vZqp_n55gT_WXRR_iZzGh_TKtDFdOsqn7Q@mail.gmail.com>
Subject: Re: Is UNSTABLE ever sent in client writes?
From: Constantine Peresypkin <pconstantine@gmail.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: multipart/alternative; boundary=001a113ed29e6bb8d805210e8021
List-ID: <linux-nfs.vger.kernel.org>

--001a113ed29e6bb8d805210e8021
Content-Type: text/plain; charset=UTF-8

The question is: can I force it to always use unstable? Or how can I debug
why FILE_SYNC is always sent in my case?
On Oct 1, 2015 12:32 PM, "Benjamin Coddington" <bcodding@redhat.com> wrote:

> On Thu, 1 Oct 2015, Constantine Peresypkin wrote:
>
> > Tried with various mount options (sync, async)
> > Looked into source code.
> > It seems like it will never be sent, client always assumes server can
> > do FILE_SYNC, and server cannot respond with anything else, if
> > implemented correctly.
> > But what we can do if the server is inherently unable to do FILE_SYNC
> > (eventual consistency, write reorder, etc.)?
>
> Hi Constantine, my linux client does unstable writes all the time.
> nfs_pgio_rpcsetup() default stable arg is NFS_UNSTABLE..
>
> Try doing a write larger than your mount's wsize parameter.
>
> Ben
>

--001a113ed29e6bb8d805210e8021
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">The question is: can I force it to always use unstable? Or h=
ow can I debug why FILE_SYNC is always sent in my case?</p>
<div class=3D"gmail_quote">On Oct 1, 2015 12:32 PM, &quot;Benjamin Coddingt=
on&quot; &lt;<a href=3D"mailto:bcodding@redhat.com">bcodding@redhat.com</a>=
&gt; wrote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Thu, =
1 Oct 2015, Constantine Peresypkin wrote:<br>
<br>
&gt; Tried with various mount options (sync, async)<br>
&gt; Looked into source code.<br>
&gt; It seems like it will never be sent, client always assumes server can<=
br>
&gt; do FILE_SYNC, and server cannot respond with anything else, if<br>
&gt; implemented correctly.<br>
&gt; But what we can do if the server is inherently unable to do FILE_SYNC<=
br>
&gt; (eventual consistency, write reorder, etc.)?<br>
<br>
Hi Constantine, my linux client does unstable writes all the time.<br>
nfs_pgio_rpcsetup() default stable arg is NFS_UNSTABLE..<br>
<br>
Try doing a write larger than your mount&#39;s wsize parameter.<br>
<br>
Ben<br>
</blockquote></div>

--001a113ed29e6bb8d805210e8021--
