From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: mountd: needless DNS queries when authenticating client against numeric IP
Date: Thu, 10 Mar 2005 12:29:06 +0200
Message-ID: <200503101222.37749.vda@ilport.com.ua>
References: <200503041424.22897.vda@ilport.com.ua> <200503090950.25722.vda@port.imtp.ilyichevsk.odessa.ua> <16943.35959.345191.659240@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>, vital@ilport.com.ua
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9Kvg-0004Xp-DZ
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 02:30:08 -0800
Received: from [195.66.192.167] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1D9KvY-0004R9-3U
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 02:30:08 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16943.35959.345191.659240@cse.unsw.edu.au>
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

> > /home	1.2.3.4(rw)
> > /public	joker(rw)
> > 
> > What is the failure scenario? I don't quite understand where is the problem.
> 
> Suppose joker is 1.2.3.4
> 
> joker mounts '/home'.  Mountd doesn't bother with the DNS lookup and
> tell the kernel:
> 
>   1/  IP address "1.2.3.4" has name "1.2.3.4"
>   2/  client with name "1.2.3.4" is allowed to access /home with
>       options "rw"
> 
> Then joker mounts '/public' so mountd need to do the DNS lookup, and
> tells the kernel:
> 
>   1/ IP address "1.2.3.4" has name "joker"
>   2/ client with name "joker" is allowed to access /public
>       with options "rw".
> 
> Now joker tries to access it's mount of /home, and this fails, because
> 1.2.3.4 maps to "joker", and "joker" doesn't have access to /home

Uggh.

BTW, I understood in-kernel NFS auth as follows:

RPC request came -> kernel translates sender's IP into name ->
kernel checks name against in-kernel export table for permissions

In-kernel export table gets (de)populated by mountd, as needed.

Correct me if I misunderstood something.

> For this reason, there must be a canonical name for each IP address.
> This has always been:
>    DNS name if it exists, else dotted-quad
> 
> We could make it always
>    dotted-quad

Sounds very sensible. Will this allow us to skip IP->name
translation in kernel entirely?

> but the former works better when you have multi-homed clients.

By keeping in-kernel export table compact? This isn't big,
you rarely have hosts with 10+ heads. Any other reasons?

> The compromise would be
>    If there are any names in /etc/exports and DNS name exists, use it,
>     else use dotted quad.
> 
> In 2.6, if /proc/fs/nfsd is mounted, the name used is a
> comma-separated list of all names mentioned in /etc/exports which
> match the IP address.

I see. I am getting familiar with how NFS internals work.
I exported / both to 127.0.0.1 and to localhost. Instrumented mountd says:

mountd: cache_export(): exp->m_client->m_addrlist[0]=127.0.0.1
mountd: cache_export(): exp->m_client->m_hostname=127.0.0.1,localhost
                                                  ^^^^^^^^^^^^^^^^^^^
mountd: cache_export_ent(): domain=127.0.0.1,localhost
mountd: cache_export_ent(): exp->e_path=/

> The same could possibly done for when /proc/fs/nfsd isn't mounted.
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
