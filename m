Return-Path: <pengyu.ut@gmail.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1503100423290.456@planck.local>
References: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com>
	<alpine.OSX.2.19.9992.1503100423290.456@planck.local>
Date: Tue, 10 Mar 2015 06:07:00 -0500
Message-ID: <CABrM6w=PoXHM9d6oSwsBK0ea7jxoyJ29TV0M_q-71qr_RykCKQ@mail.gmail.com>
Subject: Re: NFS hang after concurrent writes
From: Peng Yu <pengyu.ut@gmail.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: multipart/alternative; boundary=90e6ba6146605fd5460510ed264c
List-ID: <linux-nfs.vger.kernel.org>

--90e6ba6146605fd5460510ed264c
Content-Type: text/plain; charset=UTF-8

On Tuesday, March 10, 2015, Benjamin Coddington <bcodding@redhat.com> wrote:

> On Mon, 9 Mar 2015, Peng Yu wrote:
>
> > Hi,
> >
> > I have a home directory from an ubuntu server shared to multiple other
> > ubuntu servers as the home directory (the default login shell is bash
> > on these servers) via NFS (see the following configuration in
> > /etc/exports from the NFS server).
> >
> > /mnt/home
> 172.17.0.0/16(fsid=2,rw,insecure,no_subtree_check,sync,no_root_squash)
> >
> > autofs is used to mount the NFS on the client servers (see the
> > following configuration).
> >
> > ~$ cat /etc/auto.master
> > +auto.master
> > /home   /etc/auto.home --timeout=90
> > ~$ cat /etc/auto.home
> > *  -fstype=nfs4,rw,intr,fsc    nsfserver:/mnt/home/&
> >
> > But I frequently end up with a situation when ~/.bash_history is not
> > readable which blocks the logins to these client servers. I feel that
> > this may be related with concurrent write to ~/.bash_history from
> > these servers, which somehow screw up NFS.
>
> Hi Peng, what do you have that supports your feeling that the problem is
> conflicts on the ~/.bash_history file?  It's hard to help without more
> information.


The login process hangs when a line related to ~/.bash_history in ~/.bashrc
is being loaded. At that time, cat ~/.bash_history also hangs, but stat the
file works fine. After I delete ~/.bash_history, the login process stops
hanging.

The real difficulty is to reliably repoduce this problem in order
to pinpoint the exact cause of the problem with nfs. So far I only see the
problem with ~/.bash_history, it is hard to believe this problem is related
with the actual filename. A logic conclusion is that it must be somehow
related with how this file is written.


> You should expect NFS home directories to work and work well - it is a very
> common usage.
>
> Ben
>


-- 
Regards,
Peng

--90e6ba6146605fd5460510ed264c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br>On Tuesday, March 10, 2015, Benjamin Coddington &lt;<a href=3D"mail=
to:bcodding@redhat.com">bcodding@redhat.com</a>&gt; wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex">On Mon, 9 Mar 2015, Peng Yu wrote:<br>
<br>
&gt; Hi,<br>
&gt;<br>
&gt; I have a home directory from an ubuntu server shared to multiple other=
<br>
&gt; ubuntu servers as the home directory (the default login shell is bash<=
br>
&gt; on these servers) via NFS (see the following configuration in<br>
&gt; /etc/exports from the NFS server).<br>
&gt;<br>
&gt; /mnt/home <a href=3D"http://172.17.0.0/16(fsid=3D2,rw,insecure,no_subt=
ree_check,sync,no_root_squash)" target=3D"_blank">172.17.0.0/16(fsid=3D2,rw=
,insecure,no_subtree_check,sync,no_root_squash)</a><br>
&gt;<br>
&gt; autofs is used to mount the NFS on the client servers (see the<br>
&gt; following configuration).<br>
&gt;<br>
&gt; ~$ cat /etc/auto.master<br>
&gt; +auto.master<br>
&gt; /home=C2=A0 =C2=A0/etc/auto.home --timeout=3D90<br>
&gt; ~$ cat /etc/auto.home<br>
&gt; *=C2=A0 -fstype=3Dnfs4,rw,intr,fsc=C2=A0 =C2=A0 nsfserver:/mnt/home/&a=
mp;<br>
&gt;<br>
&gt; But I frequently end up with a situation when ~/.bash_history is not<b=
r>
&gt; readable which blocks the logins to these client servers. I feel that<=
br>
&gt; this may be related with concurrent write to ~/.bash_history from<br>
&gt; these servers, which somehow screw up NFS.<br>
<br>
Hi Peng, what do you have that supports your feeling that the problem is<br=
>
conflicts on the ~/.bash_history file?=C2=A0 It&#39;s hard to help without =
more<br>
information.</blockquote><div><br></div><div>The login process=C2=A0hangs w=
hen a line related to ~/.bash_history in=C2=A0~/.bashrc is being loaded. At=
 that time, cat=C2=A0<font><span style=3D"background-color:rgba(255,255,255=
,0)">~/.bash_history also hangs, but stat the file works fine<span></span>.=
 After I delete </span></font><span style=3D"font-size:small">~/.bash_histo=
ry,=C2=A0</span><span style=3D"background-color:rgba(255,255,255,0);font-si=
ze:small">the login process stops hanging.</span></div><div><font><span sty=
le=3D"background-color:rgba(255,255,255,0)"><br></span></font></div><div><f=
ont><span style=3D"background-color:rgba(255,255,255,0)">The real difficult=
y is to=C2=A0reliably repoduce this problem in order to=C2=A0pinpoint the e=
xact cause of the problem=C2=A0with nfs. So far I only see the problem with=
=C2=A0</span></font><span style=3D"font-size:small">~/.bash_history, it is =
hard to believe this problem is related with the actual=C2=A0filename. A lo=
gic conclusion is that it must be somehow related with how this file is wri=
tten.</span></div><div><font><span style=3D"background-color:rgba(255,255,2=
55,0)"><br></span></font></div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
You should expect NFS home directories to work and work well - it is a very=
<br>
common usage.<br>
<br>
Ben<br>
</blockquote><br><br>-- <br>Regards,<br>Peng<br>

--90e6ba6146605fd5460510ed264c--
