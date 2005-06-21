From: Fredrik Gustafsson <iveqy.mailbox@gmail.com>
Subject: Re: Access denied
Date: Tue, 21 Jun 2005 20:16:35 +0200
Message-ID: <4c45183705062111165dc92879@mail.gmail.com>
References: <4c45183705062106223f32c263@mail.gmail.com>
Reply-To: Fredrik Gustafsson <iveqy.mailbox@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DknJC-0003Ho-Jd
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 11:17:14 -0700
Received: from wproxy.gmail.com ([64.233.184.203])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DknJ2-0002OC-1r
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 11:17:14 -0700
Received: by wproxy.gmail.com with SMTP id 68so90018wra
        for <nfs@lists.sourceforge.net>; Tue, 21 Jun 2005 11:17:03 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <4c45183705062106223f32c263@mail.gmail.com>
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

I'm resending this email because I'm not sure the other one was sent.
The first mail I sent was before the registration was all done.

On 6/21/05, Fredrik Gustafsson <iveqy.mailbox@gmail.com> wrote:
> Hi, I'm having a problem with my nfs sever/client.
>=20
> This command:
> root@Arwen:~ # mount 192.168.0.107:/home /mnt/misc/
>=20
> Gives this error:
> 'mount: 192.168.0.107:/home failed, reason given by server: Access Denied
>=20
>=20
>=20
> My client is: Linux Arwen 2.6.8.1-3-386 #1 Thu Nov 18 11:47:33 UTC
> 2004 i686 GNU/Linux
>=20
> With package: Debian/Ubuntu 1.0.6-3 common and kernel server
>=20
> My server is: Linux TheServer 2.6.10-5-386 #1 Tue Apr 5 12:12:40 UTC
> 2005 i686 GNU/Linux
>=20
> With package: Debian/Ubuntu 1.0.6-3 common and kernel server
> Export file:
> # /etc/exports: the access control list for filesystems which may be expo=
rted
> #               to NFS clients.  See exports(5).
> /home 192.168.0.105(rw)
>=20
> hosts.allow:
> # /etc/hosts.allow: list of hosts that are allowed to access the system.
> #                   See the manual pages hosts_access(5), hosts_options(5=
)
> #                   and /usr/doc/netbase/portmapper.txt.gz
> #
> # Example:    ALL: LOCAL @some_netgroup
> #             ALL: .foobar.edu EXCEPT terminalserver.foobar.edu
> #
> # If you're going to protect the portmapper use the name "portmap" for th=
e
> # daemon name. Remember that you can only use the keyword "ALL" and IP
> # addresses (NOT host or domain names) for the portmapper, as well as for
> # rpc.mountd (the NFS mount daemon). See portmap(8), rpc.mountd(8) and
> # /usr/share/doc/portmap/portmapper.txt.gz for further information.
> #
> portmap: 192.168.0.105
> lockd:   192.168.0.105
> rquotad: 192.168.0.105
> mountd:  192.168.0.105
> statd:   192.168.0.105
>=20
> hosts.deny:
> # /etc/hosts.deny: list of hosts that are _not_ allowed to access the sys=
tem.
> #                  See the manual pages hosts_access(5), hosts_options(5)
> #                  and /usr/doc/netbase/portmapper.txt.gz
> #
>=20
> # Example:    ALL: some.host.name, .some.domain
> #             ALL EXCEPT in.fingerd: other.host.name, .other.domain
> #
> # If you're going to protect the portmapper use the name "portmap" for th=
e
> # daemon name. Remember that you can only use the keyword "ALL" and IP
> # addresses (NOT host or domain names) for the portmapper. See portmap(8)
> # and /usr/doc/portmap/portmapper.txt.gz for further information.
> #
> # The PARANOID wildcard matches any host whose name does not match its
> # address.
>=20
> # You may wish to enable this to ensure any programs that don't
> # validate looked up hostnames still leave understandable logs. In past
> # versions of Debian this has been the default.
> # ALL: PARANOID
> portmap:ALL
> lockd:ALL
> mountd:ALL
> rquotad:ALL
> statd:ALL
>=20
> From the server:
> root@TheServer:/etc # rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100021    1   udp  32768  nlockmgr
>     100021    3   udp  32768  nlockmgr
>     100021    4   udp  32768  nlockmgr
>     100021    1   tcp  32768  nlockmgr
>     100021    3   tcp  32768  nlockmgr
>     100021    4   tcp  32768  nlockmgr
>     100005    1   udp    678  mountd
>     100005    1   tcp    681  mountd
>     100005    2   udp    678  mountd
>     100005    2   tcp    681  mountd
>     100005    3   udp    678  mountd
>     100005    3   tcp    681  mountd
>     100024    1   udp    752  status
>     100024    1   tcp    755  status
> root@TheServer:/etc #
>=20
>=20
> From the client:
> root@Arwen:~ # rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     391002    2   tcp   1004  sgi_fam
>     100024    1   udp    811  status
>     100024    1   tcp    814  status
> root@Arwen:~ #
>=20
>=20
> hoproot@Arwen:~ # rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     391002    2   tcp   1004  sgi_fam
>     100024    1   udp    811  status
>     100024    1   tcp    814  status
> root@Arwen:~ #
>=20
>=20
> Hope someone, please, can help me...
>=20
> Regards
> iveqy
>


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
