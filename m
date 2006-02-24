From: Neil Horman <nhorman@redhat.com>
Subject: Re: Should fcntl operations check attributes with the server when NFS shares are mounted noac?
Date: Fri, 24 Feb 2006 09:06:15 -0500
Message-ID: <20060224140615.GA31881@hmsendeavour.rdu.redhat.com>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com> <1140711133.11831.27.camel@lade.trondhjem.org> <20060223192253.GG29177@hmsendeavour.rdu.redhat.com> <1140723567.7963.13.camel@lade.trondhjem.org> <43FE11F1.5040005@redhat.com> <1140725969.7963.17.camel@lade.trondhjem.org> <43FE2029.7040205@redhat.com> <1140733881.7963.31.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>,
	Neil Horman <nhorman@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCdad-0005LM-Jj
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 06:06:35 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCdac-0005P3-6N
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 06:06:35 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140733881.7963.31.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Feb 23, 2006 at 05:31:21PM -0500, Trond Myklebust wrote:
> On Thu, 2006-02-23 at 15:50 -0500, Peter Staubach wrote:
> 
> > >Will the customer be happy to find out that the application breaks in
> > >much more nefarious ways as a result of a non-working lease?
> > >
> <snip>
> > Well, it may or may not break, actually.  I would think that it would depend
> > upon what assumptions were being made by the application.
> > 
> > I would still suggest that the cost of fixing something which is clearly
> > broken is outweighed by the benefit of making a customer, at least 
> > temporarily,
> > happy.  If that customer is porting something from a system does support
> > F_SETLEASE, such as Solaris, and was happy with the way that it worked 
> > there,
> > then they may be happy with the current support of F_SETLEASE in Linux.
> > 
> > It is even possible that they were using leases for some reason instead of
> > file/record locking.  Who knows?  :-)
> 
> Precisely. In which case we should be helping them to figure out how to
> correctly set up their system in such a way that the F_SETLEASE spec
> does apply. Helping them to shoot themselves in the foot by papering
> over what is basically a symptom that _demonstrates_ they are
> misapplying it is not, in my book, good customer relations.
> 
> The bottom line is that F_SETLEASE does not work in a multi-client
> environment where more than one NFS client at a time is accessing the
> file.
> BTW: I seriously doubt F_SETLEASE on Solaris is in any better shape.
> Unless they are using some secret 3rd party protocol to ensure that
> coherency across the NFS clients, they are in exactly the same situation
> the we are.
> 
> Cheers,
>   Trond
> 

Trond, you make a good point here, after re-reading the man page for F_SETLEASE,
I agree, this operation just isn't going to work over NFS, at least not without
significant additional work.  From that standpoint we shouldn't worry about this
too much.

That being said however, the error we are discussing isn't in any way an
indicator of the brokeness which you describe above.  If, in the problem
description that I gave in my last post, the file uid had matched the process
uid on client NODE A, the fcntl operation would have succeded without a problem,
and would have happily failed to preform its function as defined in the man
page, and would have done so silently.

This strikes in a somewhat simmilar fashion to the flock() function.  For years
it just didn't work over NFS (and still IIRC doesn't), but a while ago we put in
a check so that it returned an appropriate error in the event that you tried to
flock a file over NFS.  Perhaps what we need to do here is:

1) Fix the noac problem as previously described
2) Add a check (simmilar to that of flock) such that attempting to set a lease
on a file over NFS results in a return of -ENOTSUPP or another appropriate
error.

Then when/if we decide to push for protocol support for F_SETLEASE over NFS we
can remove the check, and we don't need to revisit the attribute cache issue,
which (and I don't currently have the resources to check on this), but I think also
affects other multi-accessor file systems (CIFS, OCFS, FreeVXFS, GFS, etc)..

Thoughts?

Thanks & Regards
Neil

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
