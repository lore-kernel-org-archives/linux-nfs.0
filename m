From: Neil Horman <nhorman@redhat.com>
Subject: Re: Should fcntl operations check attributes with the server when NFS shares are mounted noac?
Date: Thu, 23 Feb 2006 14:22:53 -0500
Message-ID: <20060223192253.GG29177@hmsendeavour.rdu.redhat.com>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com> <1140711133.11831.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCM3J-0000Uh-0W
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 11:23:01 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCM3H-0004mx-Ba
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 11:23:01 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140711133.11831.27.camel@lade.trondhjem.org>
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

On Thu, Feb 23, 2006 at 11:12:13AM -0500, Trond Myklebust wrote:
> On Thu, 2006-02-23 at 07:42 -0500, Neil Horman wrote:
> > Hey all-
> > 	I've got a dillema and I'm not sure how to anwser it.  I recently had
> > someone mention to me that some of the operations executed via fcntl
> > (specifically F_SETLEASE was demonstrated to me) don't check the file attributes
> > on the server before executing their operations.  This can lead to erroneous
> > behavior in which, if someone updates file permissions or ownership from another
> > node mounting an NFS share, a node attempting to do something like a F_SETLEASE
> > operation will fail when it should succede, or vice versa.
> 
> Who is trying to use F_SETLEASE on an NFS share in these conditions? 
> 
> That is unbelievably borken: leases are supposed to guarantee that
> nobody is changing the file. If the file is being changed on the server,
> then exactly what use do they serve?
> 
> Cheers,
>   Trond
> 

The exact case that was  reported to me is as follows:

1) Client A runs a process with a uid of X that opens a file on an NFS share.
The opened file has a uid of Y.  The share is mounted with the noac option

2) Client B chmods the same file on the same share so thats its owning uid is X.

3) Client A attempts to issue a fcntl(F_SETLEASE operation on the open file
descriptor.

4) Client A has -EACCESS returned from the fcntl call.

Now, clearly, this is not the safest thing in the world to do, and the safe/race
free way to do this would be to set a file lock and stat the file before issuing
the setlease command.  But I can also see how, after reading the man page for
nfs and fcntl, one would expect this to just work if they mounted the share with
noac, under the presumption that we check the file attributes on the server
every time the client needs to check them for any purpose.  And since we don't
do that in the case of an F_SETLEASE operation, I can see how some might think
it broken.  In fact I tend to think of it as somewhat broken, but I know thats
may not be a shared view, so I was looking for input as to weather or not it was
worth fixing, and if not, why not.  If you have a good argument for why its
currently working as designed, I'll happily defer to that judgement.

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
