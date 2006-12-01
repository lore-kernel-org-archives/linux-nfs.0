From: "Paarvai Naai" <opensource3141@gmail.com>
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5
	volume!
Date: Fri, 1 Dec 2006 11:04:21 -0800
Message-ID: <52109fb10612011104l67d2f126hb53d82edb6fef64b@mail.gmail.com>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<1164228193.5694.38.camel@lade.trondhjem.org>
	<52109fb10611221443w356ff6s4eae49ebb0d935ec@mail.gmail.com>
	<1164628684.3178.10.camel@localhost>
	<52109fb10611281950s50b5d618v21c5818f12ad6b74@mail.gmail.com>
	<52109fb10612011034v4f1feb27n59b6251edee6cfc1@mail.gmail.com>
	<1164998608.16282.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0488713108=="
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>, Ian Kent <raven@themaw.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1164998608.16282.6.camel@lade.trondhjem.org>
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

--===============0488713108==
Content-Type: multipart/alternative;
	boundary="----=_Part_5644_27420104.1164999861230"

------=_Part_5644_27420104.1164999861230
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thank you for your quick response.  I'm not too familiar with the
term "injury time" and the like.  But regardless, what is the
purpose of a rc series if we can't get an important bug fix into it.

Here's what I propose and I am happy to help facilitate to
some degree.  We should definitely get it into 2.6.19.x ASAP
and obviously into 2.6.20.  And Fedora often adds extra
patches into their source RPMs.  This is the most important
for my company.  Even if we don't have it in 2.6.19 vanilla,
if I had a "certified" patch from you, we can try to take it
to Fedora and get it into their source RPM.

Thoughts?

Thanks,
Paarvai




On 12/1/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> On Fri, 2006-12-01 at 10:34 -0800, Paarvai Naai wrote:
> > Hi all,
> >
> > I really do appreciate the high quality technical assistance
> > I have gotten to date from this list.  But at the same time,
> > I am getting somewhat frustrated with the very spotty
> > attention I am getting for a *critical* bug that somehow
> > made it into the upstream kernel sources.  This is directly
> > affecting the ability to use krb5 on either NFSv3 or NFSv4.
> >
> > First I had to actually dig through the source and find the
> > bug.  Then I was offered a patch but when it didn't work
> > there was very little response/assistance to help with my
> > investigation into which kernel that patch is compatible with.
> > Finally, I have been insisting that we get the fix back into the
> > upstream sources and it appears that no one appreciates
> > the importance.
>
> 2.6.19 is already out (and by the time this bug was found, the 2.6.19-rc
> series was way into injury time).
>
> The patch will go into 2.6.20, then we can look into sending it in as a
> stable update to 2.6.19.x. Not before.
>
> Trond
>
>

------=_Part_5644_27420104.1164999861230
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thank you for your quick response.&nbsp; I'm not too familiar with the<br>term &quot;injury time&quot; and the like.&nbsp; But regardless, what is the<br>purpose of a rc series if we can't get an important bug fix into it.<br><br>Here's what I propose and I am happy to help facilitate to
<br>some degree.&nbsp; We should definitely get it into 2.6.19.x ASAP<br>and obviously into 2.6.20.&nbsp; And Fedora often adds extra<br>patches into their source RPMs.&nbsp; This is the most important<br>for my company.&nbsp; Even if we don't have it in 
2.6.19 vanilla,<br>if I had a &quot;certified&quot; patch from you, we can try to take it<br>to Fedora and get it into their source RPM.<br><br>Thoughts?<br><br>Thanks,<br>Paarvai<br><br><br><br><br><div><span class="gmail_quote">
On 12/1/06, <b class="gmail_sendername">Trond Myklebust</b> &lt;<a href="mailto:trond.myklebust@fys.uio.no">trond.myklebust@fys.uio.no</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Fri, 2006-12-01 at 10:34 -0800, Paarvai Naai wrote:<br>&gt; Hi all,<br>&gt;<br>&gt; I really do appreciate the high quality technical assistance<br>&gt; I have gotten to date from this list.&nbsp;&nbsp;But at the same time,<br>&gt; I am getting somewhat frustrated with the very spotty
<br>&gt; attention I am getting for a *critical* bug that somehow<br>&gt; made it into the upstream kernel sources.&nbsp;&nbsp;This is directly<br>&gt; affecting the ability to use krb5 on either NFSv3 or NFSv4.<br>&gt;<br>&gt; First I had to actually dig through the source and find the
<br>&gt; bug.&nbsp;&nbsp;Then I was offered a patch but when it didn't work<br>&gt; there was very little response/assistance to help with my<br>&gt; investigation into which kernel that patch is compatible with.<br>&gt; Finally, I have been insisting that we get the fix back into the
<br>&gt; upstream sources and it appears that no one appreciates<br>&gt; the importance.<br><br>2.6.19 is already out (and by the time this bug was found, the 2.6.19-rc<br>series was way into injury time).<br><br>The patch will go into 
2.6.20, then we can look into sending it in as a<br>stable update to 2.6.19.x. Not before.<br><br>Trond<br><br></blockquote></div><br>

------=_Part_5644_27420104.1164999861230--

--===============0488713108==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============0488713108==--
