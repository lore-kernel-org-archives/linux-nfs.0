From: "Paarvai Naai" <opensource3141@gmail.com>
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5
	volume!
Date: Wed, 22 Nov 2006 14:43:30 -0800
Message-ID: <52109fb10611221443w356ff6s4eae49ebb0d935ec@mail.gmail.com>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<1164228193.5694.38.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0363668443=="
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1164228193.5694.38.camel@lade.trondhjem.org>
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

--===============0363668443==
Content-Type: multipart/alternative;
	boundary="----=_Part_10396_8930649.1164235410878"

------=_Part_10396_8930649.1164235410878
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Trond,

I'm certain the problem is causing a crash on my machine.
When I am on the console and just do an umount the machine is okay
for about 2 seconds and then it crashes.  If I instead just try to do
/sbin/reboot then I see a big OOPS when the initscripts end up
unmounting the NFS filesystems, although it's hard to make sense
of it or write any info down at that point.

There is clearly something wrong but I'm starting to suspect it's
because the patch might not be appropriate for the kernels
that Kostas and I are using.  What version of the kernel (and
CITI patch, if applicable) are you making the patch against?
I'm using:

http://mirrors.kernel.org/fedora/core/updates/5/SRPMS/kernel-2.6.18-1.2200.fc5.src.rpm

Regards,
Paarvai


On 11/22/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> On Mon, 2006-11-20 at 11:47 -0800, Open Source wrote:
> > Hi Trond,
> >
> > I can confirm that I also see a crash with your patch file in place!
> > I'm not sure if that's because it didn't apply cleanly to begin with
> > and my massaging might have caused a problem.  I don't think
> > so though.
> >
> > Basically if you mount a couple NFSv3+krb5 partitions and
> > then unmount one of them, the system locks up after about 2
> > seconds.  I didn't see this before since I didn't use the
> > automounter utility.
>
> I'm unable to reproduce whether using the automounter or not. Can you be
> a bit more specific about what hangs? Are you seeing an Oops or anything
> like that?
>
> Trond
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>

------=_Part_10396_8930649.1164235410878
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Trond,<br><br>I'm certain the problem is causing a crash on my machine.<br>When I am on the console and just do an umount the machine is okay<br>for about 2 seconds and then it crashes.&nbsp; If I instead just try to do<br>/sbin/reboot then I see a big OOPS when the initscripts end up
<br>unmounting the NFS filesystems, although it's hard to make sense<br>of it or write any info down at that point.<br><br>There is clearly something wrong but I'm starting to suspect it's<br>because the patch might not be appropriate for the kernels
<br>that Kostas and I are using.&nbsp; What version of the kernel (and<br>CITI patch, if applicable) are you making the patch against?<br>I'm using:<br><br><a href="http://mirrors.kernel.org/fedora/core/updates/5/SRPMS/kernel-2.6.18-1.2200.fc5.src.rpm">
http://mirrors.kernel.org/fedora/core/updates/5/SRPMS/kernel-2.6.18-1.2200.fc5.src.rpm</a><br><br>Regards,<br>Paarvai<br><br><br><div><span class="gmail_quote">On 11/22/06, <b class="gmail_sendername">Trond Myklebust</b> &lt;
<a href="mailto:trond.myklebust@fys.uio.no">trond.myklebust@fys.uio.no</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Mon, 2006-11-20 at 11:47 -0800, Open Source wrote:<br>&gt; Hi Trond,<br>&gt;<br>&gt; I can confirm that I also see a crash with your patch file in place!<br>&gt; I'm not sure if that's because it didn't apply cleanly to begin with
<br>&gt; and my massaging might have caused a problem.&nbsp;&nbsp;I don't think<br>&gt; so though.<br>&gt;<br>&gt; Basically if you mount a couple NFSv3+krb5 partitions and<br>&gt; then unmount one of them, the system locks up after about 2
<br>&gt; seconds.&nbsp;&nbsp;I didn't see this before since I didn't use the<br>&gt; automounter utility.<br><br>I'm unable to reproduce whether using the automounter or not. Can you be<br>a bit more specific about what hangs? Are you seeing an Oops or anything
<br>like that?<br><br>Trond<br><br>_______________________________________________<br>NFSv4 mailing list<br><a href="mailto:NFSv4@linux-nfs.org">NFSv4@linux-nfs.org</a><br><a href="http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4">
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4</a><br></blockquote></div><br>

------=_Part_10396_8930649.1164235410878--

--===============0363668443==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============0363668443==--
