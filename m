From: Neil Horman <nhorman@redhat.com>
Subject: Re: Should fcntl operations check attributes with the server when NFS shares are mounted noac?
Date: Fri, 24 Feb 2006 10:25:14 -0500
Message-ID: <20060224152514.GB31881@hmsendeavour.rdu.redhat.com>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com> <1140711133.11831.27.camel@lade.trondhjem.org> <20060223192253.GG29177@hmsendeavour.rdu.redhat.com> <1140723567.7963.13.camel@lade.trondhjem.org> <43FE11F1.5040005@redhat.com> <1140725969.7963.17.camel@lade.trondhjem.org> <43FE2029.7040205@redhat.com> <1140733881.7963.31.camel@lade.trondhjem.org> <20060224140615.GA31881@hmsendeavour.rdu.redhat.com> <1140791215.3615.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@redhat.com>,
	Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCeop-0005NV-Jv
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 07:25:19 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCeoo-0006H5-8N
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 07:25:19 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140791215.3615.20.camel@lade.trondhjem.org>
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

On Fri, Feb 24, 2006 at 09:26:55AM -0500, Trond Myklebust wrote:
> On Fri, 2006-02-24 at 09:06 -0500, Neil Horman wrote:
> 
> > This strikes in a somewhat simmilar fashion to the flock() function.  For years
> > it just didn't work over NFS (and still IIRC doesn't), but a while ago we put in
> > a check so that it returned an appropriate error in the event that you tried to
> > flock a file over NFS.  Perhaps what we need to do here is:
> 
> Flock should now work over NFS. Try it.
> 
Sorry, missed the reversal of sense in the check for FL_FLOCK in nfs_flock.  But
the precedent still remains that we can check to deny access to a particular
service dependent on the underlying filesystem.

> > 1) Fix the noac problem as previously described
> > 2) Add a check (simmilar to that of flock) such that attempting to set a lease
> > on a file over NFS results in a return of -ENOTSUPP or another appropriate
> > error.
> 
> Why waste time doing (1) at all, since a "noac" mount usually means you
> are in a situation where (2) applies?
> 
If this problem only exists on NFS, then I'd tend to agree.  Although again, it
would seem that other multi-access file systems are going to suffer from the
same drawback since we never call to the underlying filesystem to get the latest
attributes.  two nodes could access a file in OCFS or GFS in the same way, and I
would expect the same problem would occur.  Do you agree?

> How about instead we do
> 
> (3) Fix the fcntl (2) manpage so that it mentions distributed
> filesystems and the caveats of using F_SETLEASE on them.
> 
Agreed, this would probably be a good idea regardless.


Regards
Neil

> Cheers,
>   Trond
> 

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
