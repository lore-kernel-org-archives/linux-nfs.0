Return-Path: <nfsv4-bounces@ietf.org>
In-Reply-To: <1132749605.180867.1323832831990.JavaMail.root@erie.cs.uoguelph.ca>
References: <4EE1EC49.6010000@panasas.com>
	<1132749605.180867.1323832831990.JavaMail.root@erie.cs.uoguelph.ca>
From: Benny Halevy <bhalevy@tonian.com>
Date: Thu, 15 Dec 2011 17:42:53 +0200
Message-ID: <CAEMWVhtQ5kZ_5zzEqd_zjqVgq3qjYy_GhE=4QYsVfgTNvb7cXA@mail.gmail.com>
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: linux-nfs@vger.kernel.org, Brent Welch <welch@panasas.com>,
        honey@citi.umich.edu, Steve Dickson <steved@redhat.com>,
        nfsv4@ietf.org
Subject: Re: [nfsv4] Slides from the pNFS BoF we delivered at LISA 11 - with
 attachment this time
List-Unsubscribe: <https://www.ietf.org/mailman/options/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============3833829838765310934=="
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============3833829838765310934==
Content-Type: multipart/alternative; boundary=14dae9399dd7b48c5704b423572c

--14dae9399dd7b48c5704b423572c
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 14, 2011 at 5:20 AM, Rick Macklem <rmacklem@uoguelph.ca> wrote:

> Boaz Harrosh wrote:
> [good stuff snipped for brevity]
> >
> > I have on my todo list a full osd (pnfs-objects) stack port to FreeBSD
> > But that's in the far future.
> > Meanwhile I'd suggest the pnfs-client-core to layout-driver API be
> > closely
> > crafted to match that of the Linux LD API so it could be kept the same
> > code base.
>
> Am I correct to assume that fs/nfs/nfsfilelayout* implements this API
> for the file layout case?



True.


> If so, I'll try and build glue that can use
> that code unchanged (or at least minimally changed).
>
> And Peter (I see you're on the cc list), is it possible to get a copy
> of these files without any GPL? It looks like they have the U of Michigan
> copyright, which I think should be fine for the FreeBSD folks, but then
> there is
>
>   MODULE_LICENSE("GPL");
>
> in it, which I assume means it's GPL'd. (Basically, exactly the same file=
,
> but released without this line, would make the FreeBSD folks happy, I
> think.)
> (No rush on this, I can use GPL'd code, I just can't put it in the FreeBS=
D
> source tree easily.) The same would apply to any other layout driver that
> others, like Panasas or EMC might be willing to open source for FreeBSD.
>

Not up to me, but it's more likely you'd be able to get the Windows code
over the university license more easily...

Benny


>
> And Boaz, thanks for the useful information. I'll probably start with
> Fedora plus a patched kernel for a server to test against. (It sounds
> like Steve is willing to help me out, since I haven't used "rpm" in
> years and have never typed "git" in my life.:-)
>
> Thanks everyone for your help with this, rick
>
>
> > For example the pnfs-objects LD is mostly pure C code
> > relying
> > on the ORE (Objects Raid Engine). The ORE is multy licensed library
> > that
> > has ports to Many platforms including Linux-Kernel
> > Linux/FreeBSD/windows User-Mode and more of which only the Linux
> > variants
> > actually run because of the need of the iscsi stack to support BiDi
> > and
> > large CDB commands, Only supported by Linux.
> >
> > Cheers
> > Boaz
> >
> > > rick
> > >
> > > ----- Original Message -----
> > >> On Thu, 08 Dec 2011 19:40:19 -0500, Sorin Faibish
> > >> <sfaibish@emc.com>
> > >> wrote:
> > >>
> > >>> Attached please find the slides that we presented yesterday at
> > >>> USENIX
> > >>> LISA 11
> > >>> conference in Boston. We would like to get more detailed input on
> > >>> other
> > >>> OS
> > >>> that will support pNFS server/client (this is for Rick as well)
> > >>> that
> > >>> were
> > >>> not mentioned in this slide set.
> > >>>
> > >>> /Sorin
> > >>>
> > >>
> > >>
> > >>
> > >> --
> > >> Best Regards
> > >> Sorin Faibish
> > >> Corporate Distinguished Engineer
> > >> Unified Storage Division
> > >>
> > >> EMC=B2
> > >> where information lives
> > >>
> > >> Phone: 508-435-1000 x 48545
> > >> Cellphone: 617-510-0422
> > >> Email : sfaibish@emc.com
> > > _______________________________________________
> > > nfsv4 mailing list
> > > nfsv4@ietf.org
> > > https://www.ietf.org/mailman/listinfo/nfsv4
> >
> > _______________________________________________
> > nfsv4 mailing list
> > nfsv4@ietf.org
> > https://www.ietf.org/mailman/listinfo/nfsv4
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
>

--14dae9399dd7b48c5704b423572c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1"><div dir=3D"ltr"><br><br><div class=3D"gmail_quote">On Wed, Dec 14, 2011=
 at 5:20 AM, Rick Macklem <span dir=3D"ltr">&lt;<a href=3D"mailto:rmacklem@=
uoguelph.ca">rmacklem@uoguelph.ca</a>&gt;</span> wrote:<br><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex">

Boaz Harrosh wrote:<br>
[good stuff snipped for brevity]<br>
<div class=3D"im">&gt;<br>
&gt; I have on my todo list a full osd (pnfs-objects) stack port to FreeBSD=
<br>
&gt; But that's in the far future.<br>
&gt; Meanwhile I'd suggest the pnfs-client-core to layout-driver API be<br>
&gt; closely<br>
&gt; crafted to match that of the Linux LD API so it could be kept the same=
<br>
&gt; code base.<br>
<br>
</div>Am I correct to assume that fs/nfs/nfsfilelayout* implements this API=
<br>
for the file layout case?</blockquote><div><br></div><div><br></div><div>Tr=
ue.</div><div>&nbsp;</div><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">If so, I'll try an=
d build glue that can use<br>


that code unchanged (or at least minimally changed).<br>
<br>
And Peter (I see you're on the cc list), is it possible to get a copy<br>
of these files without any GPL? It looks like they have the U of Michigan<b=
r>
copyright, which I think should be fine for the FreeBSD folks, but then<br>
there is<br>
<br>
 &nbsp; MODULE_LICENSE(&quot;GPL&quot;);<br>
<br>
in it, which I assume means it's GPL'd. (Basically, exactly the same file,<=
br>
but released without this line, would make the FreeBSD folks happy, I think=
.)<br>
(No rush on this, I can use GPL'd code, I just can't put it in the FreeBSD<=
br>
source tree easily.) The same would apply to any other layout driver that<b=
r>
others, like Panasas or EMC might be willing to open source for FreeBSD.<br=
></blockquote><div><br></div><div>Not up to me, but it's more likely you'd =
be able to get the Windows code</div><div>over the university license more =
easily...</div>

<div><br></div><div>Benny</div><div>&nbsp;</div><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">
<br>
And Boaz, thanks for the useful information. I'll probably start with<br>
Fedora plus a patched kernel for a server to test against. (It sounds<br>
like Steve is willing to help me out, since I haven't used &quot;rpm&quot; =
in<br>
years and have never typed &quot;git&quot; in my life.:-)<br>
<br>
Thanks everyone for your help with this, rick<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; For example the pnfs-objects LD is mostly pure C code<br>
&gt; relying<br>
&gt; on the ORE (Objects Raid Engine). The ORE is multy licensed library<br=
>
&gt; that<br>
&gt; has ports to Many platforms including Linux-Kernel<br>
&gt; Linux/FreeBSD/windows User-Mode and more of which only the Linux<br>
&gt; variants<br>
&gt; actually run because of the need of the iscsi stack to support BiDi<br=
>
&gt; and<br>
&gt; large CDB commands, Only supported by Linux.<br>
&gt;<br>
&gt; Cheers<br>
&gt; Boaz<br>
&gt;<br>
&gt; &gt; rick<br>
&gt; &gt;<br>
&gt; &gt; ----- Original Message -----<br>
&gt; &gt;&gt; On Thu, 08 Dec 2011 19:40:19 -0500, Sorin Faibish<br>
&gt; &gt;&gt; &lt;<a href=3D"mailto:sfaibish@emc.com">sfaibish@emc.com</a>&=
gt;<br>
&gt; &gt;&gt; wrote:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt;&gt; Attached please find the slides that we presented yesterd=
ay at<br>
&gt; &gt;&gt;&gt; USENIX<br>
&gt; &gt;&gt;&gt; LISA 11<br>
&gt; &gt;&gt;&gt; conference in Boston. We would like to get more detailed =
input on<br>
&gt; &gt;&gt;&gt; other<br>
&gt; &gt;&gt;&gt; OS<br>
&gt; &gt;&gt;&gt; that will support pNFS server/client (this is for Rick as=
 well)<br>
&gt; &gt;&gt;&gt; that<br>
&gt; &gt;&gt;&gt; were<br>
&gt; &gt;&gt;&gt; not mentioned in this slide set.<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; /Sorin<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; --<br>
&gt; &gt;&gt; Best Regards<br>
&gt; &gt;&gt; Sorin Faibish<br>
&gt; &gt;&gt; Corporate Distinguished Engineer<br>
&gt; &gt;&gt; Unified Storage Division<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; EMC=B2<br>
&gt; &gt;&gt; where information lives<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Phone: <a href=3D"tel:508-435-1000%20x%2048545" value=3D"&#43=
;15084351000">508-435-1000 x 48545</a><br>
&gt; &gt;&gt; Cellphone: <a href=3D"tel:617-510-0422" value=3D"&#43;1617510=
0422">617-510-0422</a><br>
&gt; &gt;&gt; Email : <a href=3D"mailto:sfaibish@emc.com">sfaibish@emc.com<=
/a><br>
&gt; &gt; _______________________________________________<br>
&gt; &gt; nfsv4 mailing list<br>
&gt; &gt; <a href=3D"mailto:nfsv4@ietf.org">nfsv4@ietf.org</a><br>
&gt; &gt; <a href=3D"https://www.ietf.org/mailman/listinfo/nfsv4" target=3D=
"_blank">https://www.ietf.org/mailman/listinfo/nfsv4</a><br>
&gt;<br>
&gt; _______________________________________________<br>
&gt; nfsv4 mailing list<br>
&gt; <a href=3D"mailto:nfsv4@ietf.org">nfsv4@ietf.org</a><br>
&gt; <a href=3D"https://www.ietf.org/mailman/listinfo/nfsv4" target=3D"_bla=
nk">https://www.ietf.org/mailman/listinfo/nfsv4</a><br>
_______________________________________________<br>
nfsv4 mailing list<br>
<a href=3D"mailto:nfsv4@ietf.org">nfsv4@ietf.org</a><br>
<a href=3D"https://www.ietf.org/mailman/listinfo/nfsv4" target=3D"_blank">h=
ttps://www.ietf.org/mailman/listinfo/nfsv4</a><br>
</div></div></blockquote></div><br></div>

--14dae9399dd7b48c5704b423572c--

--===============3833829838765310934==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============3833829838765310934==--
