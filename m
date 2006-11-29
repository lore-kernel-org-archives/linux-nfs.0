From: "Paarvai Naai" <opensource3141@gmail.com>
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5
	volume!
Date: Tue, 28 Nov 2006 19:50:05 -0800
Message-ID: <52109fb10611281950s50b5d618v21c5818f12ad6b74@mail.gmail.com>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<1164228193.5694.38.camel@lade.trondhjem.org>
	<52109fb10611221443w356ff6s4eae49ebb0d935ec@mail.gmail.com>
	<1164628684.3178.10.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2057945285=="
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: "Ian Kent" <raven@themaw.net>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1164628684.3178.10.camel@localhost>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Mime-version: 1.0
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

--===============2057945285==
Content-Type: multipart/alternative;
	boundary="----=_Part_24315_2484201.1164772205250"

------=_Part_24315_2484201.1164772205250
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I bit the bullet and compiled 2.6.19-rc6 (which was a rather
frustrating experience for a number of unrelated reasons).  In
any case, I don't see the crash there.  Hence, I'm fairly confident
that the crash had to do with an incompatibility between the
patch and 2.6.18.

Now that the patch has been verified can we do something to
get it into 2.6.19 before the final release.  This is a very serious
bug that prevents people from using krb5 on a server with two
such exports.  It needs to be fixed!

Thanks again to all the help on this list.  Hopefully we can get this
thing into the upstream kernel ASAP.

Thoughts?

Paarvai


On 11/27/06, Ian Kent <raven@themaw.net> wrote:
>
> On Wed, 2006-11-22 at 14:43 -0800, Paarvai Naai wrote:
> > Hi Trond,
> >
> > I'm certain the problem is causing a crash on my machine.
> > When I am on the console and just do an umount the machine is okay
> > for about 2 seconds and then it crashes.  If I instead just try to do
> > /sbin/reboot then I see a big OOPS when the initscripts end up
> > unmounting the NFS filesystems, although it's hard to make sense
> > of it or write any info down at that point.
>
> Doesn't it get logged.
> syslog should shutdown after autofs and NFS.
>
> Ian
>
>
>

------=_Part_24315_2484201.1164772205250
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,<br><br>I bit the bullet and compiled 2.6.19-rc6 (which was a rather<br>frustrating experience for a number of unrelated reasons).&nbsp; In<br>any case, I don't see the crash there.&nbsp; Hence, I'm fairly confident<br>that the crash had to do with an incompatibility between the
<br>patch and 2.6.18.<br><br>Now that the patch has been verified can we do something to<br>get it into 2.6.19 before the final release.&nbsp; This is a very serious<br>bug that prevents people from using krb5 on a server with two
<br>such exports.&nbsp; It needs to be fixed!<br><br>Thanks again to all the help on this list.&nbsp; Hopefully we can get this<br>thing into the upstream kernel ASAP.<br><br>Thoughts?<br><br>Paarvai<br><br><br><div><span class="gmail_quote">
On 11/27/06, <b class="gmail_sendername">Ian Kent</b> &lt;<a href="mailto:raven@themaw.net">raven@themaw.net</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Wed, 2006-11-22 at 14:43 -0800, Paarvai Naai wrote:<br>&gt; Hi Trond,<br>&gt;<br>&gt; I'm certain the problem is causing a crash on my machine.<br>&gt; When I am on the console and just do an umount the machine is okay
<br>&gt; for about 2 seconds and then it crashes.&nbsp;&nbsp;If I instead just try to do<br>&gt; /sbin/reboot then I see a big OOPS when the initscripts end up<br>&gt; unmounting the NFS filesystems, although it's hard to make sense
<br>&gt; of it or write any info down at that point.<br><br>Doesn't it get logged.<br>syslog should shutdown after autofs and NFS.<br><br>Ian<br><br><br></blockquote></div><br>

------=_Part_24315_2484201.1164772205250--

--===============2057945285==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============2057945285==--
