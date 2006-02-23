From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Should fcntl operations check attributes with the server
	when NFS shares are mounted noac?
Date: Thu, 23 Feb 2006 17:31:21 -0500
Message-ID: <1140733881.7963.31.camel@lade.trondhjem.org>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>
	 <1140711133.11831.27.camel@lade.trondhjem.org>
	 <20060223192253.GG29177@hmsendeavour.rdu.redhat.com>
	 <1140723567.7963.13.camel@lade.trondhjem.org> <43FE11F1.5040005@redhat.com>
	 <1140725969.7963.17.camel@lade.trondhjem.org> <43FE2029.7040205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Horman <nhorman@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCOzo-0004t2-G2
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 14:31:36 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCOzm-00046u-GE
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 14:31:35 -0800
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <43FE2029.7040205@redhat.com>
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

On Thu, 2006-02-23 at 15:50 -0500, Peter Staubach wrote:

> >Will the customer be happy to find out that the application breaks in
> >much more nefarious ways as a result of a non-working lease?
> >
<snip>
> Well, it may or may not break, actually.  I would think that it would depend
> upon what assumptions were being made by the application.
> 
> I would still suggest that the cost of fixing something which is clearly
> broken is outweighed by the benefit of making a customer, at least 
> temporarily,
> happy.  If that customer is porting something from a system does support
> F_SETLEASE, such as Solaris, and was happy with the way that it worked 
> there,
> then they may be happy with the current support of F_SETLEASE in Linux.
> 
> It is even possible that they were using leases for some reason instead of
> file/record locking.  Who knows?  :-)

Precisely. In which case we should be helping them to figure out how to
correctly set up their system in such a way that the F_SETLEASE spec
does apply. Helping them to shoot themselves in the foot by papering
over what is basically a symptom that _demonstrates_ they are
misapplying it is not, in my book, good customer relations.

The bottom line is that F_SETLEASE does not work in a multi-client
environment where more than one NFS client at a time is accessing the
file.
BTW: I seriously doubt F_SETLEASE on Solaris is in any better shape.
Unless they are using some secret 3rd party protocol to ensure that
coherency across the NFS clients, they are in exactly the same situation
the we are.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
