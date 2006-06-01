From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Fusing Debian patches back into nfs-utils
Date: Thu, 1 Jun 2006 18:10:15 -0400
Message-ID: <4d569c330606011510t44f65c46m9fb48a94f95692a3@mail.gmail.com>
References: <20060601155929.GA890@uio.no>
	<4d569c330606010942u6900ca96w1795b5a624ea21ee@mail.gmail.com>
	<20060601202926.GA2248@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FmIwi-0005LP-2a
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 16:20:48 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FmIwi-0008VF-4g
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 16:20:48 -0700
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FmIwh-0005rB-Q6
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 16:20:48 -0700
Received: by nf-out-0910.google.com with SMTP id o63so1110885nfa
	for <nfs@lists.sourceforge.net>; Fri, 02 Jun 2006 16:20:46 -0700 (PDT)
To: "Steinar H. Gunderson" <sesse@debian.org>
In-Reply-To: <20060601202926.GA2248@uio.no>
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

On 6/1/06, Steinar H. Gunderson <sesse@debian.org> wrote:
> On Thu, Jun 01, 2006 at 12:42:47PM -0400, Kevin Coffman wrote:
> > There is a similar issue in the svcgssd code.  However, while I was
> > looking into this, it appeared that the kernel code uses "-2" in
> > places as well.  It seems like a similar change may be needed in the
> > kernel code as well?
>
> Hm, that's possible; the change is a bit less critical for svcgssd, though,
> as the default configuration file explicitly seems to specify the user
> "nobody" (or am I thinking of the wrong user here?).

I'm talking about the case where we are unable to find a mapping for a
gss authenticated name to uid/gid and supplementary groups.  The 1.0.8
code actually has a failure there, but we really want to default to
the anonuid/anongid instead of failing to create the context.  We
could get the mappings for "nobody", but we'd really like to use the
same anonuid/anongid values as used in export.

K.C.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
