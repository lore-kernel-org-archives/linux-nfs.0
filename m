From: "H . J . Lu" <hjl@lucon.org>
Subject: Re: Re: Proposed changes for init file in nfs-utils
Date: Sun, 7 Apr 2002 20:10:43 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020407201043.A17954@lucon.org>
References: <20020406205304.C2076@ee.duke.edu> <20020407135505.A6580@lucon.org> <15537.823.811512.451102@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean O'Connell <sean@ee.duke.edu>, nfs@lists.sourceforge.net
Received: from rwcrmhc54.attbi.com ([216.148.227.87])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uPYU-0000xt-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 20:10:54 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15537.823.811512.451102@notabene.cse.unsw.edu.au>; from neilb@cse.unsw.edu.au on Mon, Apr 08, 2002 at 12:40:55PM +1000
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Mon, Apr 08, 2002 at 12:40:55PM +1000, Neil Brown wrote:
> On Sunday April 7, hjl@lucon.org wrote:
> > 
> > I checked a slightly different patch. Please check it out and make
> > sure I didn't break anything.
> 
> ...
> > +	if [ "$TUNE_QUEUE" = "yes" ]; then
> > + 	    /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null 2>&1
> > +	    /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
> > +	    /sbin/sysctl -w net.core.wmem_default=$NFSD_QS >/dev/null 2>&1
> > +	    /sbin/sysctl -w net.core.wmem_max=$NFSD_QS >/dev/null 2>&1
> > +	fi
> 
> Though it possibly doesn't hurt, there is nothing to be gained by
> setting the wmem_{default,max}.
> Only the rmem needs to be set.  This is because nfsd doesn't take
> packets off the udp queue until they are completely processed, so the
> rmem_{default,max} needs to be big enough to hold all currently active
> requests.
> 

I guess I don't have to tell you feel free to make any necessary
changes :-).


H.J.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
