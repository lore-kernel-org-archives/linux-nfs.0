From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: Proposed changes for init file in nfs-utils
Date: Mon, 8 Apr 2002 12:40:55 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15537.823.811512.451102@notabene.cse.unsw.edu.au>
References: <20020406205304.C2076@ee.duke.edu>
	<20020407135505.A6580@lucon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean O'Connell <sean@ee.duke.edu>,
    nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uP2q-0004qy-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 19:38:12 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <hjl@lucon.org>) (for <sean@ee.duke.edu>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Mon, 8 Apr 2002 12:37:53 +1000
To: "H . J . Lu" <hjl@lucon.org>
In-Reply-To: message from H . J . Lu on Sunday April 7
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

On Sunday April 7, hjl@lucon.org wrote:
> 
> I checked a slightly different patch. Please check it out and make
> sure I didn't break anything.

...
> +	if [ "$TUNE_QUEUE" = "yes" ]; then
> + 	    /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null 2>&1
> +	    /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
> +	    /sbin/sysctl -w net.core.wmem_default=$NFSD_QS >/dev/null 2>&1
> +	    /sbin/sysctl -w net.core.wmem_max=$NFSD_QS >/dev/null 2>&1
> +	fi

Though it possibly doesn't hurt, there is nothing to be gained by
setting the wmem_{default,max}.
Only the rmem needs to be set.  This is because nfsd doesn't take
packets off the udp queue until they are completely processed, so the
rmem_{default,max} needs to be big enough to hold all currently active
requests.


NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
