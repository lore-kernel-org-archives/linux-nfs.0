From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: Re: mountd: needless DNS queries when authenticating client against numeric IP
Date: Wed, 9 Mar 2005 09:27:49 -0500
Message-ID: <20050309142749.GB5027@gam3.net>
References: <200503041424.22897.vda@ilport.com.ua> <200503051557.07721.vda@ilport.com.ua> <16939.39051.569756.982757@cse.unsw.edu.au> <200503090950.25722.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D92AM-0007tt-Lz
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 06:28:02 -0800
Received: from mta13.adelphia.net ([68.168.78.44])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D92AL-0004Rf-1w
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 06:28:02 -0800
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200503090950.25722.vda@port.imtp.ilyichevsk.odessa.ua>
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

On Wed, Mar 09, 2005 at 10:49:13AM +0200, Denis Vlasenko wrote:
[snip]
> > The problem arises if someone exports one filesystem to an IP address,
> > and another to the DNS name.  Confusion and failure results.
> 
> Like this? /etc/exports:
> 
> /home	1.2.3.4(rw)
> /public	joker(rw)
> 
> What is the failure scenario? I don't quite understand where is the problem.

/home 1.2.3.0/24(ro)
/home joker(rw)

If Joker -> 1.2.3.4 then you need to do the lookup because joker is more
specific than 1.2.3.0/24.  

You could get around this by converting host names to IPs at export
time.

The precedence of exports is important as well. To do the least amount
of look up you need to make it:
IP address
hostname  (or get rid of these and only use IP addresses)
networks
wildcards

Now if you find and IP you are done. If there are not hostnames and you
find a network you are done. Otherwise you do the DNS lookup and look
for wildcards.

Allen Morris


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
