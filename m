Return-Path: <pengyu.ut@gmail.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1503100735000.456@planck.local>
References: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com>
	<alpine.OSX.2.19.9992.1503100423290.456@planck.local>
	<CABrM6w=PoXHM9d6oSwsBK0ea7jxoyJ29TV0M_q-71qr_RykCKQ@mail.gmail.com>
	<alpine.OSX.2.19.9992.1503100735000.456@planck.local>
Date: Tue, 10 Mar 2015 09:53:42 -0500
Message-ID: <CABrM6w=YWhEHfJmhVxwS3bEGn3vFjysxkay1dXS=iZVumUcpAA@mail.gmail.com>
Subject: NFS hang after concurrent writes
From: Peng Yu <pengyu.ut@gmail.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: multipart/alternative; boundary=001a113fb1581c0ba20510f05160
List-ID: <linux-nfs.vger.kernel.org>

--001a113fb1581c0ba20510f05160
Content-Type: text/plain; charset=UTF-8

On Tuesday, March 10, 2015, Benjamin Coddington <bcodding@redhat.com
<javascript:_e(%7B%7D,'cvml','bcodding@redhat.com');>> wrote:

> On Tue, 10 Mar 2015, Peng Yu wrote:
>
> >
> >
> > On Tuesday, March 10, 2015, Benjamin Coddington <bcodding@redhat.com>
> wrote:
> >       On Mon, 9 Mar 2015, Peng Yu wrote:
> >
> >       > Hi,
> >       >
> >       > I have a home directory from an ubuntu server shared to multiple
> other
> >       > ubuntu servers as the home directory (the default login shell is
> bash
> >       > on these servers) via NFS (see the following configuration in
> >       > /etc/exports from the NFS server).
> >       >
> >       > /mnt/home
> 172.17.0.0/16(fsid=2,rw,insecure,no_subtree_check,sync,no_root_squash)
> >       >
> >       > autofs is used to mount the NFS on the client servers (see the
> >       > following configuration).
> >       >
> >       > ~$ cat /etc/auto.master
> >       > +auto.master
> >       > /home   /etc/auto.home --timeout=90
> >       > ~$ cat /etc/auto.home
> >       > *  -fstype=nfs4,rw,intr,fsc    nsfserver:/mnt/home/&
> >       >
> >       > But I frequently end up with a situation when ~/.bash_history is
> not
> >       > readable which blocks the logins to these client servers. I feel
> that
> >       > this may be related with concurrent write to ~/.bash_history from
> >       > these servers, which somehow screw up NFS.
> >
> >       Hi Peng, what do you have that supports your feeling that the
> problem is
> >       conflicts on the ~/.bash_history file?  It's hard to help without
> more
> >       information.
> >
> >
> > The login process hangs when a line related to ~/.bash_history
> in ~/.bashrc is being loaded. At that time, cat ~/.bash_history
> > also hangs, but stat the file works fine. After I delete
> ~/.bash_history, the login process stops hanging.
> >
> > The real difficulty is to reliably repoduce this problem in order
> to pinpoint the exact cause of the problem with nfs. So far I
> > only see the problem with ~/.bash_history, it is hard to believe this
> problem is related with the actual filename. A logic
> > conclusion is that it must be somehow related with how this file is
> written.
>
> A network capture would be a good next step toward finding the problem.


I see something like this.

http://wiki.linux-nfs.org/wiki/index.php/General_troubleshooting_recommendations#Capturing_a_Network_Trace

Could you help show the detailed proceedure on how to do network capture to
debug this specific issue if there is anything better than that in the
above instruction ?

>
> Ben



-- 
Regards,
Peng

--001a113fb1581c0ba20510f05160
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br>On Tuesday, March 10, 2015, Benjamin Coddington &lt;<a href=3D"java=
script:_e(%7B%7D,&#39;cvml&#39;,&#39;bcodding@redhat.com&#39;);" target=3D"=
_blank">bcodding@redhat.com</a>&gt; wrote:<br><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
">On Tue, 10 Mar 2015, Peng Yu wrote:<br>
<br>
&gt;<br>
&gt;<br>
&gt; On Tuesday, March 10, 2015, Benjamin Coddington &lt;<a>bcodding@redhat=
.com</a>&gt; wrote:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0On Mon, 9 Mar 2015, Peng Yu wrote:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; Hi,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; I have a home directory from an ubuntu =
server shared to multiple other<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; ubuntu servers as the home directory (t=
he default login shell is bash<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; on these servers) via NFS (see the foll=
owing configuration in<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; /etc/exports from the NFS server).<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; /mnt/home <a href=3D"http://172.17.0.0/=
16(fsid=3D2,rw,insecure,no_subtree_check,sync,no_root_squash)" target=3D"_b=
lank">172.17.0.0/16(fsid=3D2,rw,insecure,no_subtree_check,sync,no_root_squa=
sh)</a><br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; autofs is used to mount the NFS on the =
client servers (see the<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; following configuration).<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; ~$ cat /etc/auto.master<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; +auto.master<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; /home=C2=A0 =C2=A0/etc/auto.home --time=
out=3D90<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; ~$ cat /etc/auto.home<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; *=C2=A0 -fstype=3Dnfs4,rw,intr,fsc=C2=
=A0 =C2=A0 nsfserver:/mnt/home/&amp;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; But I frequently end up with a situatio=
n when ~/.bash_history is not<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; readable which blocks the logins to the=
se client servers. I feel that<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; this may be related with concurrent wri=
te to ~/.bash_history from<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0&gt; these servers, which somehow screw up N=
FS.<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0Hi Peng, what do you have that supports your=
 feeling that the problem is<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0conflicts on the ~/.bash_history file?=C2=A0=
 It&#39;s hard to help without more<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0information.<br>
&gt;<br>
&gt;<br>
&gt; The login process=C2=A0hangs when a line related to ~/.bash_history in=
=C2=A0~/.bashrc is being loaded. At that time, cat=C2=A0~/.bash_history<br>
&gt; also hangs, but stat the file works fine. After I delete ~/.bash_histo=
ry,=C2=A0the login process stops hanging.<br>
&gt;<br>
&gt; The real difficulty is to=C2=A0reliably repoduce this problem in order=
 to=C2=A0pinpoint the exact cause of the problem=C2=A0with nfs. So far I<br=
>
&gt; only see the problem with=C2=A0~/.bash_history, it is hard to believe =
this problem is related with the actual=C2=A0filename. A logic<br>
&gt; conclusion is that it must be somehow related with how this file is wr=
itten.<br>
<br>
A network capture would be a good next step toward finding the problem.</bl=
ockquote><div><br></div><div>I see something like this.</div><div><br></div=
><div><a href=3D"http://wiki.linux-nfs.org/wiki/index.php/General_troublesh=
ooting_recommendations#Capturing_a_Network_Trace">http://wiki.linux-nfs.org=
/wiki/index.php/General_troubleshooting_recommendations#Capturing_a_Network=
_Trace</a></div><div><br></div><div>Could you help show the detailed procee=
dure on how to do net<span></span>work capture to debug this specific issue=
 if there is anything=C2=A0better <span></span>than that in=C2=A0the above =
instruction=C2=A0?=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Ben</blockquote>
<br><br>-- <br>Regards,<br>Peng<br>

--001a113fb1581c0ba20510f05160--
