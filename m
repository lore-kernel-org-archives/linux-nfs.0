From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Slow/dead NFS mounts when DNS is down
Date: Wed, 2 Mar 2005 11:28:11 +0200
Message-ID: <200503021128.11811.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6QBm-0000TD-Rq
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 01:30:42 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1D6QB3-0005YX-1z
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 01:30:42 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>
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

I have a small-to-medium net here and I refer to my internal hosts by IPs,
not names.

Unexpectedly, when external link to Inet is down, NFS mounts are slow.
I didn't expect mountd to use DNS at all if all hosts in /etc/exports
are referred with numeric IP addresses, but it does use DNS.

Narrowing it down, I edited resolv.conf in order to direct DNS queries
to non-existing host, removed 127.0.0.1 localhost from /etc/hosts
and NFS mounts did not work at all.

# cat /etc/exports
# See exports(5) for a description.
# This file contains a list of all directories exported to other computers.
# It is used by rpc.nfsd and rpc.mountd.

/       127.0.0.1(rw,no_root_squash,async)

This is what happens when I try to mount 127.0.0.1:/ (log of instrumented mountd):

11:04:15 rpc.mountd: MNT3(/) calledd
11:04:15 rpc.mountd: get_rootfh() start
11:04:15 rpc.mountd: get_rootfh() 1
11:04:15 rpc.mountd: get_rootfh() 2
11:04:15 rpc.mountd: auth_authenticate(): get_reliable_hostbyaddr start
11:04:15 rpc.mountd: get_reliable_hostbyaddr(): gethostbyaddr start
	here DNS requests time out...
11:04:25 rpc.mountd: get_reliable_hostbyaddr(): gethostbyaddr finish
11:04:25 rpc.mountd: auth_authenticate(): get_reliable_hostbyaddr finish
11:04:25 rpc.mountd: auth_authenticate(): get_hostent start
11:04:25 rpc.mountd: auth_authenticate(): get_hostent finish
11:04:25 rpc.mountd: mount request from unknown host 127.0.0.1 for / (/)

Any suggestions how to properly fix it?

Relevant part of nfsutils-1.0.7 utils/mountd/auth.c
is below sig (instrumentation not shown).

Code flow:
get_reliable_hostbyaddr (DNS timeount) -> get_hostent ->
-> while(1){...} -> switch (error){ ->
-> case unknown_host: -> "mount request from unknown host..."
--
vda

        hp = get_reliable_hostbyaddr((const char*)&caller->sin_addr, sizeof(struct in_addr),
                                     AF_INET);
        if (!hp)
                hp = get_hostent((const char*)&caller->sin_addr, sizeof(struct in_addr),
                                     AF_INET);
        if (!hp)
                return exp;

        /* Try the longest matching exported pathname. */
        while (1) {
                exp = auth_authenticate_internal(what, caller, epath,
                                                 hp, &error);
                if (exp || (error != not_exported && error != no_entry))
                        break;
                /* We have to treat the root, "/", specially. */
                if (p == &epath[1]) break;
                p = strrchr(epath, '/');
                if (p == epath) p++;
                *p = '\0';
        }

        switch (error) {
        case bad_path:
                xlog(L_WARNING, "bad path in %s request from %s: \"%s\"",
                     what, inet_ntoa(addr), path);
                break;

        case unknown_host:
                xlog(L_WARNING, "%s request from unknown host %s for %s (%s)",



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
