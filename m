From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: mountd: needless DNS queries when authenticating client against numeric IP
Date: Mon, 7 Mar 2005 10:55:55 +1100
Message-ID: <16939.39051.569756.982757@cse.unsw.edu.au>
References: <200503041424.22897.vda@ilport.com.ua>
	<200503051557.07721.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>, vital@ilport.com.ua
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D85bO-0005xZ-HG
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 15:56:02 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D85bM-0003fy-Pa
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 15:56:02 -0800
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: message from Denis Vlasenko on Saturday March 5
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

On Saturday March 5, vda@ilport.com.ua wrote:
> On Friday 04 March 2005 14:24, Denis Vlasenko wrote:
> > mount 127.0.0.1:/ can fail if DNS is down
> > and mountd has been restarted without re-run of exportfs -r,
> > because /var/lib/nfs/etab contains wrong hostname ("localhost"
> > instead of "127.0.0.1") and mountd cannot determine that
> > these are the same. This was explained in my previous mail.
> > 
> > Here is another, lesser problem:
> > 
> > If mountd was restarted _with_ prior run of exportfs -r, etab is correct
> > and mount succeeds, but with ~10 sec delay because of DNS timeout
> [snip]
> 
> I've cooked up a patch.
> Now my mount 127.0.0.1:/ /mnt/tmp succeeds instantly,
> regardless of whether 127.0.0.1 resolves to 'localhost' or not.
> 
> This is accomplished by first trying to auth against numeric IP,
> and only if that fails, we resolve IP into name and try again.
> 
> Please comment/apply.

sorry, but this has been tried before, and it doesn't work.

 From the ChangeLog
	
2001-09-12 NeilBrown <neilb@cse.unsw.edu.au>

	* utils/mountd/auth.c (auth_authenticate_internal): Reverse
	  change from 2000-08-02:  It causes problems if someone exports
	  to both a hostname and IP addresses.  nfs-utils must be
	  consistant about the canonical name that it chooses.
...
2000-08-02  H.J. Lu <hjl@lucon.org>

	* utils/mountd/auth.c (auth_authenticate_internal): Try to
	avoid the reverse name lookup.

It is only safe to avoid the DNS lookup if there are *no* names in the
/etc/exports file.  If everything is one of "*", "ip.ad.dr.es" or 
"ne.t-.wo.rk/mask"  then it is OK,  If there is any domain.name or
@netgroup, then you always need to find the name.
The problem arises if someone exports one filesystem to an IP address,
and another to the DNS name.  Confusion and failure results.

A patch which checked is this was the case, and always avoided DNS
lookup if it was would be seriously considered for acceptance.

Thanks,
NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
