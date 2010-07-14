From: Christopher Weis <ccweis@gmail.com>
Subject: Re: remote I/O error nfs4err_resource
Date: Wed, 14 Jul 2010 17:13:50 -0500
Message-ID: <AANLkTimWHroU6HnqNmjTslbyVZCnlKfEkBrx3fGKTGRf@mail.gmail.com>
References: <AANLkTikoGWqS01RMgUpKNS3d6BIF7h7Lmo80Tm50XZpf@mail.gmail.com>
	<1279145187.9967.58.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0529005633=="
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1279145187.9967.58.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

--===============0529005633==
Content-Type: multipart/alternative; boundary=0015175cf73cee997e048b604c44

--0015175cf73cee997e048b604c44
Content-Type: text/plain; charset=ISO-8859-1

That helps.  Thanks!

~Chris

On Wed, Jul 14, 2010 at 5:06 PM, Trond Myklebust <Trond.Myklebust@netapp.com
> wrote:

> On Wed, 2010-07-14 at 16:14 -0500, Christopher Weis wrote:
> > I just joined the list, so sorry for the lack of an inline response.
> >  I appear to be running into the same issue recently discussed here...
> > http://marc.info/?l=linux-nfsv4&m=127732700529997&w=2
> > The thread was left with the following note: "The only solution to that
> problem, as far as I know, is to hunt down those clients which are keeping
> huge numbers of open files and/or locks, and possibly move them to a
> different server."
> > In my case, there is only one client, and I'm dealing with a relatively
> low file count.  Read/write delegations are disabled within ONTAP, and
> something as simple as a "cp -r" or a "tar" of the local /usr filesystem to
> the NetApp volume using NFSv4 triggers the remote I/O error.  NFSv3 works
> fine.  Perhaps there is something else going on inside of ONTAP
> >
> > So, my questions are:
> > 1) Is this believed to be an ONTAP issue or a Linux issue (or both)?
> > 2) Is Trond's recent patch set (
> http://thread.gmane.org/gmane.linux.nfs/33353) expected to fix the issue?
> > 3) Are there known kernel bugzilla or NetApp BURTs to track the issue(s)?
>
> OnTAP has a fixed size table of stateids: that is a known limitation,
> but it is also a deliberate choice in order to ensure that the server
> resources can be managed in a predictable manner.
> OnTAP also has a bug which can affect you when you turn on delegations:
> if the server runs out of free stateid table slots, then the natural
> thing would be for it to start asking clients to return delegations.
> This is not yet implemented in OnTAP and so Burt 388695 is tracking this
> issue.
>
> Current versions of Linux have an issue when you use file locking: they
> can end up using a lot of stateids if you have one or several
> applications does a lot of lock/unlock cycles but where the file stateid
> never gets CLOSEd (which can happen if at least one application has the
> file open at any point in time). That is a bug that the above patch set
> aims to fix by adding client side support for the RELEASE_LOCKOWNER
> operation.
>
> Older versions of Linux also had a problem with delegation management:
> instead of returning delegations for files that had seen no recent
> activity, they would continue to hoard them until either the server
> recalled them, or the entire inode dropped out of cache, or the
> application performed some action that required the delegation return.
> This has been fixed since Linux 2.6.29: we now return delegations that
> have seen no activity in the last lease period.
>
> Cheers
>   Trond
>

--0015175cf73cee997e048b604c44
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

That helps. =A0Thanks!<div><br></div><div>~Chris<br><br><div class=3D"gmail=
_quote">On Wed, Jul 14, 2010 at 5:06 PM, Trond Myklebust <span dir=3D"ltr">=
&lt;<a href=3D"mailto:Trond.Myklebust@netapp.com">Trond.Myklebust@netapp.co=
m</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div><div></div><div class=3D"h5">On Wed, 2=
010-07-14 at 16:14 -0500, Christopher Weis wrote:<br>
&gt; I just joined the list, so sorry for the lack of an inline response.<b=
r>
&gt; =A0I appear to be running into the same issue recently discussed here.=
..<br>
&gt; <a href=3D"http://marc.info/?l=3Dlinux-nfsv4&amp;m=3D127732700529997&a=
mp;w=3D2" target=3D"_blank">http://marc.info/?l=3Dlinux-nfsv4&amp;m=3D12773=
2700529997&amp;w=3D2</a><br>
&gt; The thread was left with the following note: &quot;The only solution t=
o that problem, as far as I know, is to hunt down those clients which are k=
eeping huge numbers of open files and/or locks, and possibly move them to a=
 different server.&quot;<br>

&gt; In my case, there is only one client, and I&#39;m dealing with a relat=
ively low file count. =A0Read/write delegations are disabled within ONTAP, =
and something as simple as a &quot;cp -r&quot; or a &quot;tar&quot; of the =
local /usr filesystem to the NetApp volume using NFSv4 triggers the remote =
I/O error. =A0NFSv3 works fine. =A0Perhaps there is something else going on=
 inside of ONTAP<br>

&gt;<br>
&gt; So, my questions are:<br>
&gt; 1) Is this believed to be an ONTAP issue or a Linux issue (or both)?<b=
r>
&gt; 2) Is Trond&#39;s recent patch set (<a href=3D"http://thread.gmane.org=
/gmane.linux.nfs/33353" target=3D"_blank">http://thread.gmane.org/gmane.lin=
ux.nfs/33353</a>) expected to fix the issue?<br>
&gt; 3) Are there known kernel bugzilla or NetApp BURTs to track the issue(=
s)?<br>
<br>
</div></div>OnTAP has a fixed size table of stateids: that is a known limit=
ation,<br>
but it is also a deliberate choice in order to ensure that the server<br>
resources can be managed in a predictable manner.<br>
OnTAP also has a bug which can affect you when you turn on delegations:<br>
if the server runs out of free stateid table slots, then the natural<br>
thing would be for it to start asking clients to return delegations.<br>
This is not yet implemented in OnTAP and so Burt 388695 is tracking this<br=
>
issue.<br>
<br>
Current versions of Linux have an issue when you use file locking: they<br>
can end up using a lot of stateids if you have one or several<br>
applications does a lot of lock/unlock cycles but where the file stateid<br=
>
never gets CLOSEd (which can happen if at least one application has the<br>
file open at any point in time). That is a bug that the above patch set<br>
aims to fix by adding client side support for the RELEASE_LOCKOWNER<br>
operation.<br>
<br>
Older versions of Linux also had a problem with delegation management:<br>
instead of returning delegations for files that had seen no recent<br>
activity, they would continue to hoard them until either the server<br>
recalled them, or the entire inode dropped out of cache, or the<br>
application performed some action that required the delegation return.<br>
This has been fixed since Linux 2.6.29: we now return delegations that<br>
have seen no activity in the last lease period.<br>
<br>
Cheers<br>
<font color=3D"#888888"> =A0Trond<br>
</font></blockquote></div><br></div>

--0015175cf73cee997e048b604c44--

--===============0529005633==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org instead.
(To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org.)

NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============0529005633==--
