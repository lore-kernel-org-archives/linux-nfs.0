From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: mountd: needless DNS queries when authenticating client against numeric IP
Date: Wed, 9 Mar 2005 10:49:13 +0200
Message-ID: <200503090950.25722.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200503041424.22897.vda@ilport.com.ua> <200503051557.07721.vda@ilport.com.ua> <16939.39051.569756.982757@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8wt0-0001I4-Vw
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 00:49:46 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1D8wsw-0007KA-B7
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 00:49:46 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <16939.39051.569756.982757@cse.unsw.edu.au>
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

> > > mount 127.0.0.1:/ can fail if DNS is down
> > > and mountd has been restarted without re-run of exportfs -r,
> > > because /var/lib/nfs/etab contains wrong hostname ("localhost"
> > > instead of "127.0.0.1") and mountd cannot determine that
> > > these are the same. This was explained in my previous mail.
> > > 
> > > Here is another, lesser problem:
> > > 
> > > If mountd was restarted _with_ prior run of exportfs -r, etab is correct
> > > and mount succeeds, but with ~10 sec delay because of DNS timeout
> > [snip]
> > 
> > I've cooked up a patch.
> > Now my mount 127.0.0.1:/ /mnt/tmp succeeds instantly,
> > regardless of whether 127.0.0.1 resolves to 'localhost' or not.
> > 
> > This is accomplished by first trying to auth against numeric IP,
> > and only if that fails, we resolve IP into name and try again.
> > 
> > Please comment/apply.
> 
> sorry, but this has been tried before, and it doesn't work.
> 
>  From the ChangeLog
> 	
> 2001-09-12 NeilBrown <neilb@cse.unsw.edu.au>
> 
> 	* utils/mountd/auth.c (auth_authenticate_internal): Reverse
> 	  change from 2000-08-02:  It causes problems if someone exports
> 	  to both a hostname and IP addresses.  nfs-utils must be
> 	  consistant about the canonical name that it chooses.
> ...
> 2000-08-02  H.J. Lu <hjl@lucon.org>
> 
> 	* utils/mountd/auth.c (auth_authenticate_internal): Try to
> 	avoid the reverse name lookup.
> 
> It is only safe to avoid the DNS lookup if there are *no* names in the
> /etc/exports file.  If everything is one of "*", "ip.ad.dr.es" or 
> "ne.t-.wo.rk/mask"  then it is OK,  If there is any domain.name or
> @netgroup, then you always need to find the name.

What about '*.domain.name' style wildcards?

> The problem arises if someone exports one filesystem to an IP address,
> and another to the DNS name.  Confusion and failure results.

Like this? /etc/exports:

/home	1.2.3.4(rw)
/public	joker(rw)

What is the failure scenario? I don't quite understand where is the problem.
--
vda



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
