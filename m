From: Mark Cooke <mpc@star.sr.bham.ac.uk>
Subject: Re: Mailbox corruption on The NFS server
Date: Wed, 03 Dec 2003 12:36:00 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1070454960.4793.28.camel@pc24.sr.bham.ac.uk>
References: <Pine.GSO.4.44.0312031704460.20659-100000@bhairav.ee.iitb.ac.in>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Shivaji Navale <shivaji@ee.iitb.ac.in>
In-Reply-To: <Pine.GSO.4.44.0312031704460.20659-100000@bhairav.ee.iitb.ac.in>
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

Hi,

Shouldn't need to change the NFS server as maildir was specifically
designed to operate with NFS and lockfree schemes.

Useful links:

http://cr.yp.to/proto/maildir.html          (Info on maildir)
http://www.firstpr.com.au/web-mail/mb2md/   (Convert mbox to mdir)

Cheers,

Mark

On Wed, 2003-12-03 at 11:38, Shivaji Navale wrote:
> Thanks a lot!!
> i would try it out and post the results for perusage.
> 
> Would this solve the corruption problem.
> 
> Is it that this entire issue is because of pine and sendmail.
> And configuring either properly would eradicate the problem.
> So NFS doesnt need to be messed with.
> 
> thanks
> -shivaji
> 
> 
> -- EVERYONE should contribute to THE BEST of their capacity
> for THE DEVELOPMENT of THE NATION
> 					 -- A P J KALAM
> 
> On Wed, 3 Dec 2003, Mark Cooke wrote:
> 
> > You have to wait for the lock to be released - sendmail doesn't know if
> > pine is partway through changing the mailbox file.
> >
> > Alternatively, switch to using maildir rather than mailbox.  Locking
> > isn't required at that point - but I believe you have to patch pine for
> > maildir support.
> >
> > Mark
> >
> > On Wed, 2003-12-03 at 10:56, Shivaji Navale wrote:
> > > On 2 Dec 2003, Trond Myklebust wrote:
> > >
> > > > >>>>> " " == Juri Haberland <list-linux.nfs@spoiled.org> writes:
> > > >
> > > >      > It's considered a bad idea to put mailboxes on a NFS share as
> > > >      > there might be locking issues if two applications simultanously
> > > >      > acces the same mailbox. Either use the maildir format or don't
> > > >      > export your mailboxes via NFS.
> > > >
> > > > Sort of. It can be made to work *provided* that you can guarantee that
> > > > your mail programs all agree to support the same file locking scheme.
> > > > Currently that means they must chose one (or both) of the following
> > > > schemes:
> > > >
> > > >   - fcntl() (a.k.a. POSIX, a.k.a. lockf()) locking
> > > >
> > > >   - dotlocking (a.k.a. creating a lock file using something like 'ln
> > > >     mailbox .mailbox.locked')
> > > >
> > > > Note that the BSD flock() and use of O_EXCL in a dotlocking scheme are
> > > > not considered to be reliable within Linux NFS.
> > >
> > > We use sendmail as our MTA and  pine for mails, the dotlocking feature is
> > > there with pine. And it appears  sendmail on invoking procmail waits for
> > > this lock to be released, if it exists.
> > >
> > > Is there a way out of this, or rather not have mailboxes exported to
> > > clients.
> > >
> > > thanks,
> > > shivaji...
> > >
> > > PS:sorry, for starting new thread from an old one.
> > >
> > >
> > >
> > >
> > > >
> > > > Cheers,
> > > >   Trond
> > > >
> > > >
> > > > -------------------------------------------------------
> > > > This SF.net email is sponsored by: SF.net Giveback Program.
> > > > Does SourceForge.net help you be more productive?  Does it
> > > > help you create better code?  SHARE THE LOVE, and help us help
> > > > YOU!  Click Here: http://sourceforge.net/donate/
> > > > _______________________________________________
> > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > > >
> > >
> > >
> > >
> > > -------------------------------------------------------
> > > This SF.net email is sponsored by: SF.net Giveback Program.
> > > Does SourceForge.net help you be more productive?  Does it
> > > help you create better code?  SHARE THE LOVE, and help us help
> > > YOU!  Click Here: http://sourceforge.net/donate/
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > --
> > Mark Cooke <mpc@star.sr.bham.ac.uk>
> > University Of Birmingham
> >
-- 
Mark Cooke <mpc@star.sr.bham.ac.uk>
University Of Birmingham



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
