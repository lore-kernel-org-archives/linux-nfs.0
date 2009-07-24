Return-Path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090724184429.GA16811@fieldses.org>
References: <200907231510.LAA43979@snowhite.cis.uoguelph.ca>
	<2CFD9099-9CE1-479D-99D0-80C4E5FA58F4@netapp.com>
	<20090724184429.GA16811@fieldses.org>
Date: Fri, 24 Jul 2009 15:32:47 -0400
Message-ID: <fe2cbb740907241232j49e672fbvb60512e35e5ac0ff@mail.gmail.com>
Subject: Re: nfs4 write delegation status
From: "David V. Cloud" <david.v.cloud@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org,
        erveith@de.ibm.com, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============0527362971=="
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============0527362971==
Content-Type: multipart/alternative; boundary=0016367ed50846d437046f78ab29

--0016367ed50846d437046f78ab29
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

A simple one could be found in the following paper,

http://www.usenix.org/events/fast07/tech/full_papers/gulati/gulati_html/nache.html


-David


On Fri, Jul 24, 2009 at 2:44 PM, J. Bruce Fields <bfields@fieldses.org>wrote:

> On Thu, Jul 23, 2009 at 02:11:46PM -0400, Andy Adamson wrote:
> >
> > On Jul 23, 2009, at 11:10 AM, Rick Macklem wrote:
> >
> >>>> I really don't want to enable write delegations until we figure
> >>>> out how
> >>>> to enforce them correctly against local (non-nfs) users of the
> >>>> exported
> >>>> filesystem as well.  In addition to breaking delegations on read
> >>>> opens,
> >>>> that means breaking delegations or doing a cb_getattr on
> >>>> operations like
> >>>> stat.
> >>>
> >>> do you know whether there are local FS where the maintainers at
> >>> least plan
> >>> to incorporate delegations?
> >>
> >> I'm not a Linux guy, so I'm not familiar with the internal structure,
> >> but...
> >> in general, I don't think the problem is with local file systems.
> >> Usually
> >> the problem is with local system call access. For example, if a
> >> process running locally on the server opens a file, the delegation
> >> should
> >> be recalled, so that changes done locally on the client get flushed
> >> back
> >> to the server. Also, a write delegation allows a client to do byte
> >> range
> >> locking locally in the client, so the write delegation needs to be
> >> recalled before anything gets a byte range lock locally in the server.
> >
> > The delegation implementation on the Linux server uses the vfs lease
> > subsystem, and so is integrated with local access - conflicting opens
> > done locally do recall delegations.  But the last time I looked, the
> > lease subsystem is not complete as it doesn't recall leases (nor
> > delegations) on remove, rename, etc. Another problem is that while write
> > delegations improve performance for certain workloads, they kill
> > performance for others.
>
> Are there any published results yet with real workloads?
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--0016367ed50846d437046f78ab29
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">A simple one could be found in the following paper, <br><br><a href=3D"h=
ttp://www.usenix.org/events/fast07/tech/full_papers/gulati/gulati_html/nach=
e.html">http://www.usenix.org/events/fast07/tech/full_papers/gulati/gulati_=
html/nache.html</a><br>
<br><br>-David<br><br><br><div class=3D"gmail_quote">On Fri, Jul 24, 2009 a=
t 2:44 PM, J. Bruce Fields <span dir=3D"ltr">&lt;<a href=3D"mailto:bfields@=
fieldses.org">bfields@fieldses.org</a>&gt;</span> wrote:<br><blockquote cla=
ss=3D"gmail_quote" style=3D"border-left: 1px solid rgb(204, 204, 204); marg=
in: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
<div><div></div><div class=3D"h5">On Thu, Jul 23, 2009 at 02:11:46PM -0400,=
 Andy Adamson wrote:<br>
&gt;<br>
&gt; On Jul 23, 2009, at 11:10 AM, Rick Macklem wrote:<br>
&gt;<br>
&gt;&gt;&gt;&gt; I really don't want to enable write delegations until we f=
igure<br>
&gt;&gt;&gt;&gt; out how<br>
&gt;&gt;&gt;&gt; to enforce them correctly against local (non-nfs) users of=
 the<br>
&gt;&gt;&gt;&gt; exported<br>
&gt;&gt;&gt;&gt; filesystem as well. &nbsp;In addition to breaking delegati=
ons on read<br>
&gt;&gt;&gt;&gt; opens,<br>
&gt;&gt;&gt;&gt; that means breaking delegations or doing a cb_getattr on<b=
r>
&gt;&gt;&gt;&gt; operations like<br>
&gt;&gt;&gt;&gt; stat.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; do you know whether there are local FS where the maintainers a=
t<br>
&gt;&gt;&gt; least plan<br>
&gt;&gt;&gt; to incorporate delegations?<br>
&gt;&gt;<br>
&gt;&gt; I'm not a Linux guy, so I'm not familiar with the internal structu=
re,<br>
&gt;&gt; but...<br>
&gt;&gt; in general, I don't think the problem is with local file systems.<=
br>
&gt;&gt; Usually<br>
&gt;&gt; the problem is with local system call access. For example, if a<br=
>
&gt;&gt; process running locally on the server opens a file, the delegation=
<br>
&gt;&gt; should<br>
&gt;&gt; be recalled, so that changes done locally on the client get flushe=
d<br>
&gt;&gt; back<br>
&gt;&gt; to the server. Also, a write delegation allows a client to do byte=
<br>
&gt;&gt; range<br>
&gt;&gt; locking locally in the client, so the write delegation needs to be=
<br>
&gt;&gt; recalled before anything gets a byte range lock locally in the ser=
ver.<br>
&gt;<br>
&gt; The delegation implementation on the Linux server uses the vfs lease<b=
r>
&gt; subsystem, and so is integrated with local access - conflicting opens<=
br>
&gt; done locally do recall delegations. &nbsp;But the last time I looked, =
the<br>
&gt; lease subsystem is not complete as it doesn't recall leases (nor<br>
&gt; delegations) on remove, rename, etc. Another problem is that while wri=
te<br>
&gt; delegations improve performance for certain workloads, they kill<br>
&gt; performance for others.<br>
<br>
</div></div>Are there any published results yet with real workloads?<br>
<font color=3D"#888888"><br>
--b.<br>
</font><div><div></div><div class=3D"h5">--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-nfs&qu=
ot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at &nbsp;<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
</div></div></blockquote></div><br>

--0016367ed50846d437046f78ab29--

--===============0527362971==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============0527362971==--
