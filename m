From: Ragnar =?iso-8859-15?Q?Kj=F8rstad?= <linux-ha@ragnark.vestdata.no>
Subject: Re: Linux NFS & Heartbeat Failover (RH9.0)
Date: Sat, 16 Aug 2003 16:57:18 +0200
Sender: linux-ha-admin@lists.linux-ha.org
Message-ID: <20030816145718.GO28475@vestdata.no>
References: <1061042243.3f3e3843de979@mail.aidasystems.com>
Reply-To: linux-ha@lists.linux-ha.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <linux-ha-admin@lists.linux-ha.org>
To: linux-ha@lists.linux-ha.org, nfs@lists.sourceforge.net,
   Tim Hasson <tim@aidasystems.com>
In-Reply-To: <1061042243.3f3e3843de979@mail.aidasystems.com>
Errors-To: linux-ha-admin@lists.linux-ha.org
List-Unsubscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=unsubscribe>
List-Post: <mailto:linux-ha@lists.linux-ha.org>
List-Help: <mailto:linux-ha-request@lists.linux-ha.org?subject=help>
List-Subscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=subscribe>
List-Archive: <http://lists.linux-ha.org/pipermail/linux-ha/>
List-ID: <nfs.lists.sourceforge.net>

On Sat, Aug 16, 2003 at 06:57:23AM -0700, Tim Hasson wrote:
> Summary:
> NFS Client is unable to connect to nfs server started under heartbeat through 
> virtual IP.
> 
> I have a very similar setup. 2 Redhat 9.0 (2.4.20-19.9smp) boxes running DRBD -
>  Network RAID 1 -
>  and NFS Server +statd+portmap+fam under heartbeat 1.0.3

portmap doesn't need to be, but that's probably ok.

> I have edited the default /etc/init.d/nfslock script to start rpc.statd with 
> the option -n vitualIP so that when NFS server crashes and falls over to the 
> secondary, I shouldn't have problems from clients complaining that the statd 
> host changed.

That should get your locking working, but just note that the -n option
does not affect the interface used for responses.

> However, like him, I got the same error when trying to mount an exported 
> directory from the NFS Server via the virtual IP of the 2-node heartbeat 
> cluster.
> The error is: NFSPROC_NULL: RPC: Timed out
> 
> Running tcpdump on the primary node like so:
> tcpdump -np -s 1600 udp port 2049
> gives some interesting info, especially when I retry mounting by the virtual 
> ip from the nfs client. It looks like the server accepts the connection on the 
> virtual ip (i.e. eth0:0) but nfsd on port 2049 replies using the primary 
> interface ip (i.e. eth0). The client doesn't like the reply from different 
> host I guess therefore timing out.
> 
> rpcinfo -e nfs.server.virtual.ip (from the client) works as expected.
> showmount -e nfs.server.virt.ip  (from the client) works as expected also.

I do not recall having this problem before; indicating that it is a new
one. (I haven't configured failover nfs-server on recent
kernels/nfs-utils).

First, what version of nfs-utils do you use? If you have an old one,
upgrade to nfs-utils v1.0.5; I've seen simular problems go away with
v1.0.5, even if they were not supposed to :)

Also, check that you have a recent glibc-version. (I belive there is a
glibc in RH9 updates ?) - there used to be a problem in glibc about
which interface to send packets on or something like that.


If that doesn't help, the only thing I can offer is a possible
workaround; use ip from the iproute-package to configure the 
source-address for outgoing packets.


If you get a tip offlist; please forward it to me as I have plans to
write an HA-NFS howto, and would like to include this problem and it's
solution.




> I tried modifying /etc/ha.d/resources.d/IPaddr so that the ip is assigned in 
> add_address() to eth0 statically instead of the eth#:# and also in 
> delete_address, and although I was able to mount now from the clients, 
> heartbeat stop doesn't seem to stop the services anymore and I see errors 
> reported in /var/log/ha-log about IPaddr error 1

I don't know the details of the problem, but it's definitively not the
"right way" to solve the problem. The host should be available with a
static ip independent of it's status (active/inactive), so replacing the
address on eth0 is not a good idea. (I guess for servers with two
ethernet-cards one could use eth1 instead of eth0:0 for the virtual
address, but...)



-- 
Ragnar Kjørstad
_______________________________________________
Linux-HA mailing list
Linux-HA@lists.linux-ha.org
http://lists.linux-ha.org/mailman/listinfo/linux-ha
