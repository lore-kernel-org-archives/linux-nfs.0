From: "Christopher Smith" <csmithere@gmail.com>
Subject: Re: Update to the NFS Howto
Date: Mon, 12 Jun 2006 09:33:07 -0400
Message-ID: <2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com>
References: <4489840C0200006B0000515A@lucius.provo.novell.com>
	<2b585fc90606120403w755dfe76gb185ca135eed3732@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpmXZ-00065f-1m
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 06:33:13 -0700
Received: from py-out-1112.google.com ([64.233.166.178])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FpmXY-0007J4-Ns
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 06:33:13 -0700
Received: by py-out-1112.google.com with SMTP id x31so1689898pye
	for <nfs@lists.sourceforge.net>; Mon, 12 Jun 2006 06:33:07 -0700 (PDT)
To: "Chakravarthi P" <pchakravarthi@novell.com>
In-Reply-To: <2b585fc90606120403w755dfe76gb185ca135eed3732@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Chax--

Thank you very much for what you have submitted.  A few comments:

a) Some of the information tin the README is general to Linux, and
applies to all 2.6 implementations.
b) Some of the information here applies to SuSE specifically.
c) The Kerberos configuration section applies to both NFS Version 3 as
well as NFS Version 4.

What I would suggest is we do the following:

* Break out the portions that apply specifically to NFS Version 4 into
sections 3 and 4 of the HOWTO for server and client configuration.
* Break out the Kerberos documentation you've generated into a
subsection of the Security portion of the HOWTO, since it applies to
all NFS versions.
* Add notation where specific SuSE related configuration is required.

Either you or I can do this.  Its up to you.

Is this acceptable?

Best,
CMS

On 6/12/06, Christopher Smith <csmithere@gmail.com> wrote:
> Chax--
>
> I'm in the process of reviewing the content of the README you have
> submitted, and I will get back to you shortly.
>
> Best,
> CMS
>
> On 6/9/06, Chakravarthi P <pchakravarthi@novell.com> wrote:
> > All-
> >
> >    we have compiled a README for setting up NFSv4 client
> >    and server which works well on SLES.
> >    Can this be inclused as part of nfs-howto
> >    mentioned here.
> >    Please look through the attached README
> >
> >    thanx
> >    chax.
> >
> > >>> On 6/5/2006 at 10:30:06 pm, in message
> > <6AF36215-733E-42C0-9395-B836740E50FB@gmail.com>, "Christopher M. Smith"
> > <csmithere@gmail.com> wrote:
> > > All--
> > >
> > > I have put a draft update of the NFS-Howto up on the
> > > nfs,sourceforge.net website.  It contains no new content, but
> > > encompasses the following changes:
> > >
> > > 1. A slightly different CSS style sheet to enhance its readability.
> > > 2. It has been updated to DocBook XML v4.2.
> > >
> > > The draft is located here:
> > >
> > > http://nfs.sourceforge.net/nfs-howtov4/
> > >
> > > Please let me know if you have any questions or comments.  If I have
> > > not heard negative feedback by the end of the week, I will migrate
> > > the new content to be the primary version.
> > >
> > > Thank you for your time.
> > >
> > > Best,
> > > CMS
> > > --
> > > Christopher M. Smith
> > > csmithere@gmail.com
> > >
> > >
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nf
> >
> >
> >
> >
> >
>
>
> --
> CMS
> --
> Christopher M. Smith
> csmithere@gmail.com
>


-- 
CMS
--
Christopher M. Smith
csmithere@gmail.com


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
