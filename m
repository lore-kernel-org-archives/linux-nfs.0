From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: mountd: needless DNS queries when authenticating client against numeric IP
Date: Thu, 10 Mar 2005 10:53:27 +1100
Message-ID: <16943.35959.345191.659240@cse.unsw.edu.au>
References: <200503041424.22897.vda@ilport.com.ua>
	<200503051557.07721.vda@ilport.com.ua>
	<16939.39051.569756.982757@cse.unsw.edu.au>
	<200503090950.25722.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Vlasenko <vda@ilport.com.ua>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>, vital@ilport.com.ua
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9Azv-0001X9-AE
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 15:53:51 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D9Azt-0002NP-D8
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 15:53:51 -0800
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: message from Denis Vlasenko on Wednesday March 9
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

On Wednesday March 9, vda@port.imtp.ilyichevsk.odessa.ua wrote:
> > 
> > It is only safe to avoid the DNS lookup if there are *no* names in the
> > /etc/exports file.  If everything is one of "*", "ip.ad.dr.es" or 
> > "ne.t-.wo.rk/mask"  then it is OK,  If there is any domain.name or
> > @netgroup, then you always need to find the name.
> 
> What about '*.domain.name' style wildcards?
> 

Yep,  Always need DNS lookup if there are any of those too.

> > The problem arises if someone exports one filesystem to an IP address,
> > and another to the DNS name.  Confusion and failure results.
> 
> Like this? /etc/exports:
> 
> /home	1.2.3.4(rw)
> /public	joker(rw)
> 
> What is the failure scenario? I don't quite understand where is the problem.

Suppose joker is 1.2.3.4

joker mounts '/home'.  Mountd doesn't bother with the DNS lookup and
tell the kernel:

  1/  IP address "1.2.3.4" has name "1.2.3.4"
  2/  client with name "1.2.3.4" is allowed to access /home with
      options "rw"

Then joker mounts '/public' so mountd need to do the DNS lookup, and
tells the kernel:

  1/ IP address "1.2.3.4" has name "joker"
  2/ client with name "joker" is allowed to access /public
      with options "rw".


Now joker tries to access it's mount of /home, and this fails, because
1.2.3.4 maps to "joker", and "joker" doesn't have access to /home


For this reason, there must be a canonical name for each IP address.
This has always been:
   DNS name if it exists, else dotted-quad

We could make it always
   dotted-quad

but the former works better when you have multi-homed clients.

The compromise would be
   If there are any names in /etc/exports and DNS name exists, use it,
    else used dotted quad.

In 2.6, if /proc/fs/nfsd is mounted, the name used is a
comma-separated list of all names mentioned in /etc/exports which
match the IP address.

The same could possibly done for when /proc/fs/nfsd isn't mounted.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
