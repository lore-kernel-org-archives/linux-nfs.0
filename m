From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH/RFC 1/2] rpcproxyd
Date: Mon, 14 Mar 2005 20:24:40 +0100
Message-ID: <20050314192440.GC29939@suse.de>
References: <37086.66.11.176.22.1110228763.squirrel@webmail1.hrnoc.net> <37093.66.11.176.22.1110228819.squirrel@webmail1.hrnoc.net> <20050314105249.GH14815@suse.de> <48275.66.11.176.22.1110821698.squirrel@webmail1.hrnoc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <nfs@lists.sourceforge.net>,
	autofs mailing list <autofs@linux.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAvBE-0004KD-Ny
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 11:24:44 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DAvBD-0005yN-0P
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 11:24:44 -0800
To: mike@waychison.com
In-Reply-To: <48275.66.11.176.22.1110821698.squirrel@webmail1.hrnoc.net>
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

Hi Mike,

On Mon, Mar 14, 2005 at 12:34:58PM -0500, mike@waychison.com wrote:
> > 	For instance, I can connect to your service, and fork off
> > 	some setuid root application, with stderr connected to that
> > 	socket. Any error message the application prints will be arrive
> > 	with uid 0. If I manage to make that message appear valid to you,
> > 	your daemon will accept any future input unquestioned.
> >
> 
> Interesting attack, although I doubt the setuid program would be attaching
> an SCM_CREDENTIALS to it's stderr writes.  I'll fix it up to check
> credentials on all packets nevertheless.

The application doesn't have to pass them explicitly. They'll be
attached automatically by the kernel.

> > 	If you make it less generic, and allow only mount calls, you'll
> > 	be much safer, because in the case of a bug, an attacker will
> > 	be able to send fake MOUNT packets, but nothing else.
> >
> 
> Hmm.  I like the idea of keeping it generic as it may very well solve
> someone else's problem as well.   As for locking it down to MOUNT (and
> possibly PMAP/RPCB), how about some sort of config file that limits
> PROG/VERS tuples?

That works as well.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
