Return-Path: <nfsv4-bounces@ietf.org>
In-Reply-To: <20131028210247.GM31322@fieldses.org>
References: <1382920068.6932.46.camel@heisenberg.scientia.net>
	<2E672741-FE4F-4287-8D00-B7634A71709E@netapp.com>
	<526E8562.3040809@redhat.com>
	<1382976943.8774.10.camel@heisenberg.scientia.net>
	<FD29488A-348B-48BA-9B1D-4ACF997BC794@netapp.com>
	<526EA65A.7010209@redhat.com> <20131028180838.GG31322@fieldses.org>
	<526EAD86.6090507@redhat.com>
	<OFA4C7B613.86F16AC7-ON88257C12.006FE486-88257C12.0071EE79@us.ibm.com>
	<C2C70C2E-100E-40BD-A919-A4F649077059@netapp.com>
	<20131028210247.GM31322@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OF2A1D5A37.7078A337-ON88257C12.0073FC23-88257C12.0075F998@us.ibm.com>
Date: Mon, 28 Oct 2013 14:28:34 -0700
Cc: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        "Haynes,
	Tom" <Tom.Haynes@netapp.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        "nfsv4@ietf.org nfsv4@ietf.org" <nfsv4@ietf.org>,
        Steve Dickson <SteveD@redhat.com>,
        "Myklebust,
	Trond" <Trond.Myklebust@netapp.com>,
        Ric Wheeler <ric.wheeler@usenix.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>
Subject: Re: [nfsv4] XATTRs in NFS?
List-Unsubscribe: <https://www.ietf.org/mailman/options/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============6599115206786229813=="
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============6599115206786229813==
Content-Type: multipart/alternative; boundary="=_alternative 00754A1988257C12_="

--=_alternative 00754A1988257C12_=
Content-Type: text/plain; charset="US-ASCII"

"J. Bruce Fields" <bfields@fieldses.org> wrote on 10/28/2013 02:02:47 PM:

> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: "Haynes, Tom" <Tom.Haynes@netapp.com>, 
> Cc: Marc Eshel/Almaden/IBM@IBMUS, Spencer Shepler 
> <spencer.shepler@gmail.com>, Mailing List Linux NFS <linux-
> nfs@vger.kernel.org>, Christoph Anton Mitterer 
> <calestyo@scientia.net>, "Myklebust, Trond" 
> <Trond.Myklebust@netapp.com>, Steve Dickson <SteveD@redhat.com>, 
> "nfsv4@ietf.org nfsv4@ietf.org" <nfsv4@ietf.org>, Ric Wheeler 
> <ric.wheeler@usenix.org>, "linux-nfs-owner@vger.kernel.org" <linux-
> nfs-owner@vger.kernel.org>
> Date: 10/28/2013 02:02 PM
> Subject: Re: [nfsv4] XATTRs in NFS?
> 
> On Mon, Oct 28, 2013 at 08:55:06PM +0000, Haynes, Tom wrote:
> > 
> > On Oct 28, 2013, at 1:44 PM, Marc Eshel <eshel@us.ibm.com> wrote:
> > 
> > > Hi Spencer, 
> > > Is it still possible to get on the agenda fir IETF 88, I just 
> got approval 
> > > to travel. We can use about 15 minutes, or what ever is available to 

> > > discussion the future of named attributes in NFS. The two main 
questions 
> > > that we need answer are: 
> > > 1. Do we need them? what applications use them and how. 
> > > 2. Can we have a more simple model that handles just user 
attributes.
> > > 
> > > Input is welcome to help me make the case at the meeting.
> > > 
> > > Thanks, Marc.
> > > 
> > 
> > 
> > Be sure to call out why they currently do or do not work.
> 
> And we also need to keep clear the distinctions between:
> 
>    - NFSv4 named attributes/streams/forks and "extended attributes"
>      as implemented in Linux and elsewhere.
>    - user.* xattrs and "back-door ioctls".
> 
> (Your description above seems to confuse named attributes and Linux
> extended attributes.)

Yes, I used user which is the Linux type of xattr but what I meant is 
somthing like the Linux user attributes with no special meaning to NFS, so 
NFS can be used to just transfer opaque attributes. 
Marc.


> 
> --b.
> 

--=_alternative 00754A1988257C12_=
Content-Type: text/html; charset="US-ASCII"

<meta http-equiv="Content-Type" content="text/html; charset=us-ascii"><br><tt><font size="2">&quot;J. Bruce Fields&quot; &lt;bfields@fieldses.org&gt;
wrote on 10/28/2013 02:02:47 PM:<br>
<br>
&gt; From: &quot;J. Bruce Fields&quot; &lt;bfields@fieldses.org&gt;</font></tt>
<br><tt><font size="2">&gt; To: &quot;Haynes, Tom&quot; &lt;Tom.Haynes@netapp.com&gt;,
</font></tt>
<br><tt><font size="2">&gt; Cc: Marc Eshel/Almaden/IBM@IBMUS, Spencer Shepler
<br>
&gt; &lt;spencer.shepler@gmail.com&gt;, Mailing List Linux NFS &lt;linux-<br>
&gt; nfs@vger.kernel.org&gt;, Christoph Anton Mitterer <br>
&gt; &lt;calestyo@scientia.net&gt;, &quot;Myklebust, Trond&quot; <br>
&gt; &lt;Trond.Myklebust@netapp.com&gt;, Steve Dickson &lt;SteveD@redhat.com&gt;,
<br>
&gt; &quot;nfsv4@ietf.org nfsv4@ietf.org&quot; &lt;nfsv4@ietf.org&gt;,
Ric Wheeler <br>
&gt; &lt;ric.wheeler@usenix.org&gt;, &quot;linux-nfs-owner@vger.kernel.org&quot;
&lt;linux-<br>
&gt; nfs-owner@vger.kernel.org&gt;</font></tt>
<br><tt><font size="2">&gt; Date: 10/28/2013 02:02 PM</font></tt>
<br><tt><font size="2">&gt; Subject: Re: [nfsv4] XATTRs in NFS?</font></tt>
<br><tt><font size="2">&gt; <br>
&gt; On Mon, Oct 28, 2013 at 08:55:06PM &#43;0000, Haynes, Tom wrote:<br>
&gt; &gt; <br>
&gt; &gt; On Oct 28, 2013, at 1:44 PM, Marc Eshel &lt;eshel@us.ibm.com&gt;
wrote:<br>
&gt; &gt; <br>
&gt; &gt; &gt; Hi Spencer, <br>
&gt; &gt; &gt; Is it still possible to get on the agenda fir IETF 88, I
just <br>
&gt; got approval <br>
&gt; &gt; &gt; to travel. We can use about 15 minutes, or what ever is
available to <br>
&gt; &gt; &gt; discussion the future of named attributes in NFS. The two
main questions <br>
&gt; &gt; &gt; that we need answer are: <br>
&gt; &gt; &gt; 1. Do we need them? what applications use them and how.
<br>
&gt; &gt; &gt; 2. Can we have a more simple model that handles just user
attributes.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; Input is welcome to help me make the case at the meeting.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; Thanks, Marc.<br>
&gt; &gt; &gt; <br>
&gt; &gt; <br>
&gt; &gt; <br>
&gt; &gt; Be sure to call out why they currently do or do not work.<br>
&gt; <br>
&gt; And we also need to keep clear the distinctions between:<br>
&gt; <br>
&gt; &nbsp; &nbsp;- NFSv4 named attributes/streams/forks and &quot;extended
attributes&quot;<br>
&gt; &nbsp; &nbsp; &nbsp;as implemented in Linux and elsewhere.<br>
&gt; &nbsp; &nbsp;- user.* xattrs and &quot;back-door ioctls&quot;.<br>
&gt; <br>
&gt; (Your description above seems to confuse named attributes and Linux<br>
&gt; extended attributes.)</font></tt>
<br>
<br><tt><font size="2">Yes, I used user which is the Linux type of xattr
but what I meant is somthing like the Linux user attributes with no special
meaning to NFS, so NFS can be used to just transfer opaque attributes.
&nbsp;</font></tt>
<br><tt><font size="2">Marc.</font></tt>
<br>
<br><tt><font size="2"><br>
&gt; <br>
&gt; --b.<br>
&gt; <br>
</font></tt>
--=_alternative 00754A1988257C12_=--

--===============6599115206786229813==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============6599115206786229813==--
