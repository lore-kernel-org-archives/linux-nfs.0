From: Noam Meltzer <noam@primarydata.com>
Subject: Re: [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
Date: Thu, 20 Mar 2014 09:33:45 +0200
Message-ID: <CAOoFWK_uNLEim7MH=K=Ojge_KjcJk6V7p1-LFcYNPC9=fZ90fQ@mail.gmail.com>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
	<5321CDB6.7010803@RedHat.com>
	<1394729939.32465.231.camel@willson.li.ssimo.org>
	<20140313172531.GA7124@fieldses.org>
	<1394732462.32465.235.camel@willson.li.ssimo.org>
Reply-To: Development of the System Security Services Daemon
	<sssd-devel@lists.fedorahosted.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6974286707529319790=="
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
	Steve Dickson <SteveD@redhat.com>,
	sssd-devel <sssd-devel@lists.fedorahosted.org>
To: Simo Sorce <simo@redhat.com>
Return-path: <sssd-devel-bounces@lists.fedorahosted.org>
In-Reply-To: <1394732462.32465.235.camel-Hs+ccMQdwurzDu64bZtGtWD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.fedorahosted.org/mailman/options/sssd-devel>,
	<mailto:sssd-devel-request@lists.fedorahosted.org?subject=unsubscribe>
List-Archive: <https://lists.fedorahosted.org/pipermail/sssd-devel/>
List-Post: <mailto:sssd-devel@lists.fedorahosted.org>
List-Help: <mailto:sssd-devel-request@lists.fedorahosted.org?subject=help>
List-Subscribe: <https://lists.fedorahosted.org/mailman/listinfo/sssd-devel>,
	<mailto:sssd-devel-request@lists.fedorahosted.org?subject=subscribe>
Sender: sssd-devel-bounces@lists.fedorahosted.org
Errors-To: sssd-devel-bounces@lists.fedorahosted.org
List-ID: <linux-nfs.vger.kernel.org>

--===============6974286707529319790==
Content-Type: multipart/alternative; boundary=089e0115ec1415b15704f504ca88

--089e0115ec1415b15704f504ca88
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Mar 13, 2014 at 7:41 PM, Simo Sorce <simo@redhat.com> wrote:

> On Thu, 2014-03-13 at 13:25 -0400, J. Bruce Fields wrote:
> > On Thu, Mar 13, 2014 at 12:58:59PM -0400, Simo Sorce wrote:
> > > On Thu, 2014-03-13 at 11:24 -0400, Steve Dickson wrote:
> > >
> > > > V4 servers now have an option of returning a uid string (aka "3606")
> > > > where the NFS client just converts that into the uid.
> > >
> > > Can the client tell the server *not to do that* ?
> >
> > The client can use kerberos, in which case the server won't do that.
>
> This is sufficient, thanks.
>
> > Other than that, no, the behavior can only be controlled by server-side
> > configuration.
>
> A little sub-optimal if the server can do either but the client can have
> a choice, but ok.
>

Sorry for the late response. A misplaced email filtering rule had moved it
away from my inbox.
How can we push this forward?

-- 
Noam Meltzer
Linux Software Engineer
PRIMARY DATA

P.O. Box 12650, Herzliya Pituach 4673300
9 Hamenofim St. Akerstein Towers, Tower A, 5th fl. Herzliya

Office: +972-77-8981888 | Fax: +972-3-7617140 | Mobile: +972-54-5873843

Email: noam@primarydata.com

--089e0115ec1415b15704f504ca88
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Thu, Mar 13, 2014 at 7:41 PM, Simo Sorce <span dir=3D"ltr">&lt;<=
a href=3D"mailto:simo@redhat.com" target=3D"_blank">simo@redhat.com</a>&gt;=
</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"">On Thu, 2014-03-13 at 13:25 =
-0400, J. Bruce Fields wrote:<br>
&gt; On Thu, Mar 13, 2014 at 12:58:59PM -0400, Simo Sorce wrote:<br>
&gt; &gt; On Thu, 2014-03-13 at 11:24 -0400, Steve Dickson wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; V4 servers now have an option of returning a uid string (aka=
 &quot;3606&quot;)<br>
&gt; &gt; &gt; where the NFS client just converts that into the uid.<br>
&gt; &gt;<br>
&gt; &gt; Can the client tell the server *not to do that* ?<br>
&gt;<br>
&gt; The client can use kerberos, in which case the server won&#39;t do tha=
t.<br>
<br>
</div>This is sufficient, thanks.<br>
<div class=3D""><br>
&gt; Other than that, no, the behavior can only be controlled by server-sid=
e<br>
&gt; configuration.<br>
<br>
</div>A little sub-optimal if the server can do either but the client can h=
ave<br>
a choice, but ok.<br></blockquote></div><br></div><div class=3D"gmail_extra=
">Sorry for the late response. A misplaced email filtering rule had moved i=
t away from my inbox.<br></div><div class=3D"gmail_extra">How can we push t=
his forward?<br clear=3D"all">
</div><div class=3D"gmail_extra"><br>-- <br><div dir=3D"ltr"><table cellpad=
ding=3D"0" cellspacing=3D"0"><tbody><tr><td>Noam Meltzer<br>Linux Software =
Engineer<br>PRIMARY DATA<br><br>P.O. Box 12650, Herzliya Pituach 4673300<br=
>9 Hamenofim St. Akerstein Towers, Tower A, 5th fl. Herzliya<br>
<br>Office: +972-77-8981888 | Fax: +972-3-7617140 | Mobile: +972-54-5873843=
<br><br>Email: <a href=3D"mailto:noam@primarydata.com" target=3D"_blank">no=
am@primarydata.com</a><br></td><td><span><label></label></span><br></td></t=
r>
</tbody></table></div>
</div></div>

--089e0115ec1415b15704f504ca88--

--===============6974286707529319790==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18Kc3NzZC1kZXZl
bCBtYWlsaW5nIGxpc3QKc3NzZC1kZXZlbEBsaXN0cy5mZWRvcmFob3N0ZWQub3JnCmh0dHBzOi8v
bGlzdHMuZmVkb3JhaG9zdGVkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3Nzc2QtZGV2ZWwK

--===============6974286707529319790==--
