From: Marc Eshel <eshel@us.ibm.com>
Subject: Re: XATTRs in NFS?
Date: Mon, 28 Oct 2013 14:28:35 -0700
Message-ID: <OF3A48E6D9.7BB93CB0-ON88257C12.0075527E-88257C12.0075F9B5@us.ibm.com>
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
	<6AB20096-3993-47DD-AB58-2CD25F8A75D8@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8523528931232107062=="
Cc: Mailing List Linux NFS <linux-nfs@vger.kernel.org>, "Haynes,
	Tom" <Tom.Haynes@netapp.com>,
	Christoph Anton Mitterer <calestyo@scientia.net>,
	"nfsv4@ietf.org nfsv4@ietf.org" <nfsv4@ietf.org>,
	Steve Dickson <SteveD@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Ric Wheeler <ric.wheeler@usenix.org>, "Myklebust,
	Trond" <Trond.Myklebust@netapp.com>,
	"linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@ietf.org>
In-Reply-To: <6AB20096-3993-47DD-AB58-2CD25F8A75D8@oracle.com>
List-Unsubscribe: <https://www.ietf.org/mailman/options/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multipart message in MIME format.
--===============8523528931232107062==
Content-Type: multipart/alternative; boundary="=_alternative 0075F15C88257C12_="

This is a multipart message in MIME format.
--=_alternative 0075F15C88257C12_=
Content-Type: text/plain; charset="US-ASCII"

linux-nfs-owner@vger.kernel.org wrote on 10/28/2013 02:04:57 PM:

> From: Chuck Lever <chuck.lever@oracle.com>
> To: "J. Bruce Fields" <bfields@fieldses.org>, 
> Cc: "Haynes, Tom" <Tom.Haynes@netapp.com>, Marc Eshel/Almaden/
> IBM@IBMUS, Spencer Shepler <spencer.shepler@gmail.com>, Mailing List
> Linux NFS <linux-nfs@vger.kernel.org>, Christoph Anton Mitterer 
> <calestyo@scientia.net>, "Myklebust, Trond" 
> <Trond.Myklebust@netapp.com>, Steve Dickson <SteveD@redhat.com>, 
> "nfsv4@ietf.org nfsv4@ietf.org" <nfsv4@ietf.org>, Ric Wheeler 
> <ric.wheeler@usenix.org>, "linux-nfs-owner@vger.kernel.org" <linux-
> nfs-owner@vger.kernel.org>
> Date: 10/28/2013 02:07 PM
> Subject: Re: [nfsv4] XATTRs in NFS?
> Sent by: linux-nfs-owner@vger.kernel.org
> 
> 
> On Oct 28, 2013, at 5:02 PM, "J. Bruce Fields" <bfields@fieldses.org> 
wrote:
> 
> > On Mon, Oct 28, 2013 at 08:55:06PM +0000, Haynes, Tom wrote:
> >> 
> >> On Oct 28, 2013, at 1:44 PM, Marc Eshel <eshel@us.ibm.com> wrote:
> >> 
> >>> Hi Spencer, 
> >>> Is it still possible to get on the agenda fir IETF 88, I just 
> got approval 
> >>> to travel. We can use about 15 minutes, or what ever is available to 

> >>> discussion the future of named attributes in NFS. The two main 
questions 
> >>> that we need answer are: 
> >>> 1. Do we need them? what applications use them and how. 
> >>> 2. Can we have a more simple model that handles just user 
attributes.
> >>> 
> >>> Input is welcome to help me make the case at the meeting.
> >>> 
> >>> Thanks, Marc.
> >>> 
> >> 
> >> 
> >> Be sure to call out why they currently do or do not work.
> > 
> > And we also need to keep clear the distinctions between:
> > 
> >    - NFSv4 named attributes/streams/forks and "extended attributes"
> >      as implemented in Linux and elsewhere.
> >    - user.* xattrs and "back-door ioctls".
> > 
> > (Your description above seems to confuse named attributes and Linux
> > extended attributes.)
> 
> I wonder if we will have a balanced discussion next week.  The 
> people who seem to know the most about these issues on Linux will 
> not be attending.  Perhaps it would be better to start this 
> discussion on the mailing list instead.

Like I said input is welcome to the mailing list and I can try to collect 
all the main points into a presentation at the IETF. The main objective 
for now is to see if this is an item for the working group to start 
dealing with for future NFS protocol enhancements.
Marc.

> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--=_alternative 0075F15C88257C12_=
Content-Type: text/html; charset="US-ASCII"


<br><tt><font size=2>linux-nfs-owner@vger.kernel.org wrote on 10/28/2013
02:04:57 PM:<br>
<br>
&gt; From: Chuck Lever &lt;chuck.lever@oracle.com&gt;</font></tt>
<br><tt><font size=2>&gt; To: &quot;J. Bruce Fields&quot; &lt;bfields@fieldses.org&gt;,
</font></tt>
<br><tt><font size=2>&gt; Cc: &quot;Haynes, Tom&quot; &lt;Tom.Haynes@netapp.com&gt;,
Marc Eshel/Almaden/<br>
&gt; IBM@IBMUS, Spencer Shepler &lt;spencer.shepler@gmail.com&gt;, Mailing
List<br>
&gt; Linux NFS &lt;linux-nfs@vger.kernel.org&gt;, Christoph Anton Mitterer
<br>
&gt; &lt;calestyo@scientia.net&gt;, &quot;Myklebust, Trond&quot; <br>
&gt; &lt;Trond.Myklebust@netapp.com&gt;, Steve Dickson &lt;SteveD@redhat.com&gt;,
<br>
&gt; &quot;nfsv4@ietf.org nfsv4@ietf.org&quot; &lt;nfsv4@ietf.org&gt;,
Ric Wheeler <br>
&gt; &lt;ric.wheeler@usenix.org&gt;, &quot;linux-nfs-owner@vger.kernel.org&quot;
&lt;linux-<br>
&gt; nfs-owner@vger.kernel.org&gt;</font></tt>
<br><tt><font size=2>&gt; Date: 10/28/2013 02:07 PM</font></tt>
<br><tt><font size=2>&gt; Subject: Re: [nfsv4] XATTRs in NFS?</font></tt>
<br><tt><font size=2>&gt; Sent by: linux-nfs-owner@vger.kernel.org</font></tt>
<br><tt><font size=2>&gt; <br>
&gt; <br>
&gt; On Oct 28, 2013, at 5:02 PM, &quot;J. Bruce Fields&quot; &lt;bfields@fieldses.org&gt;
wrote:<br>
&gt; <br>
&gt; &gt; On Mon, Oct 28, 2013 at 08:55:06PM +0000, Haynes, Tom wrote:<br>
&gt; &gt;&gt; <br>
&gt; &gt;&gt; On Oct 28, 2013, at 1:44 PM, Marc Eshel &lt;eshel@us.ibm.com&gt;
wrote:<br>
&gt; &gt;&gt; <br>
&gt; &gt;&gt;&gt; Hi Spencer, <br>
&gt; &gt;&gt;&gt; Is it still possible to get on the agenda fir IETF 88,
I just <br>
&gt; got approval <br>
&gt; &gt;&gt;&gt; to travel. We can use about 15 minutes, or what ever
is available to <br>
&gt; &gt;&gt;&gt; discussion the future of named attributes in NFS. The
two main questions <br>
&gt; &gt;&gt;&gt; that we need answer are: <br>
&gt; &gt;&gt;&gt; 1. Do we need them? what applications use them and how.
<br>
&gt; &gt;&gt;&gt; 2. Can we have a more simple model that handles just
user attributes.<br>
&gt; &gt;&gt;&gt; <br>
&gt; &gt;&gt;&gt; Input is welcome to help me make the case at the meeting.<br>
&gt; &gt;&gt;&gt; <br>
&gt; &gt;&gt;&gt; Thanks, Marc.<br>
&gt; &gt;&gt;&gt; <br>
&gt; &gt;&gt; <br>
&gt; &gt;&gt; <br>
&gt; &gt;&gt; Be sure to call out why they currently do or do not work.<br>
&gt; &gt; <br>
&gt; &gt; And we also need to keep clear the distinctions between:<br>
&gt; &gt; <br>
&gt; &gt; &nbsp; &nbsp;- NFSv4 named attributes/streams/forks and &quot;extended
attributes&quot;<br>
&gt; &gt; &nbsp; &nbsp; &nbsp;as implemented in Linux and elsewhere.<br>
&gt; &gt; &nbsp; &nbsp;- user.* xattrs and &quot;back-door ioctls&quot;.<br>
&gt; &gt; <br>
&gt; &gt; (Your description above seems to confuse named attributes and
Linux<br>
&gt; &gt; extended attributes.)<br>
&gt; <br>
&gt; I wonder if we will have a balanced discussion next week. &nbsp;The
<br>
&gt; people who seem to know the most about these issues on Linux will
<br>
&gt; not be attending. &nbsp;Perhaps it would be better to start this <br>
&gt; discussion on the mailing list instead.</font></tt>
<br>
<br><tt><font size=2>Like I said input is welcome to the mailing list and
I can try to collect all the main points into a presentation at the IETF.
The main objective for now is to see if this is an item for the working
group to start dealing with for future NFS protocol enhancements.</font></tt>
<br><tt><font size=2>Marc.</font></tt>
<br><tt><font size=2><br>
&gt; <br>
&gt; --<br>
&gt; Chuck Lever<br>
&gt; chuck[dot]lever[at]oracle[dot]com<br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; --<br>
&gt; To unsubscribe from this list: send the line &quot;unsubscribe linux-nfs&quot;
in<br>
&gt; the body of a message to majordomo@vger.kernel.org<br>
&gt; More majordomo info at &nbsp;</font></tt><a href="http://vger.kernel.org/majordomo-info.html"><tt><font size=2>http://vger.kernel.org/majordomo-info.html</font></tt></a><tt><font size=2><br>
&gt; <br>
</font></tt>
--=_alternative 0075F15C88257C12_=--


--===============8523528931232107062==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============8523528931232107062==--
