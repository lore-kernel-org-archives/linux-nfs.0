From: Tim Hasson <tim@aidasystems.com>
Subject: Re: Linux NFS, DRBD, and Heartbeat Failover
Date: Sat, 16 Aug 2003 18:35:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1061084130.3f3edbe2e3799@mail.aidasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [208.253.240.78] (helo=mx1.aidasystems.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19oCa9-0004tR-00
	for <nfs@lists.sourceforge.net>; Sat, 16 Aug 2003 18:43:45 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi List,

I guess like Juan said, my question would be what happened
with the patches for supporting NFS over distributed filesystems?

Please read below for more info..

Best Regards,
Tim


----- Forwarded message from Juan Gomez <juang@us.ibm.com> -----
    Date: Sat, 16 Aug 2003 17:48:06 -0700
    From: Juan Gomez <juang@us.ibm.com>
 Subject: Re: Linux NFS, DRBD, and Heartbeat Failover
      To: Tim Hasson <tim@aidasystems.com>





Tim

Long time since I worked on this but in summary: we did get a patched
version of kernel NFS/LOCKd to do NFS server takeover correctly. I did
maill all the patches to Alan and frequently asked for status but finally
got tired and gave up.

There were some issues with some of the patched for lockd: the ones I
submitted were single threaded and they wanted multithreaded so they did
not wanted to include them. I did not had the time to multithread it before
this project was out of my scope.

We did not used linux heartbeat software but instead a home-brewed cluster
software but I guess the issues are the same.

Regarding the changes in user-level NFS related code all of them where
taken in, they did have a very good response to them so you should find
them in the regular distribution.

I would say best way to check status on this would be to ask what happen
with the patches for supporting NFS over distributed filesystems, once
again.


Regards, Juan



                                                                               
                                
                      Tim 
Hasson                                                                         
      
                      <tim@aidasystems.        To:       Juan 
Gomez/Almaden/IBM@IBMUS                          
                      com>                     
cc:                                                             
                                               Subject:  Linux NFS, DRBD, and 
Heartbeat Failover               
                      08/16/03 05:23 
AM                                                                        
                                                                               
                                
                                                                               
                                




Hi,

I would like to ask you on the status of a problem you were looking at
earlier
and I would really appreciate any information.
The link I followed was:
http://www.cs.helsinki.fi/linux/linux-kernel/2002-46/0767.html

A link of someone who had the same problem (I think):
http://lists.linux-ha.org/pipermail/linux-ha/2003-March/007269.html

Summary:
NFS Client is unable to connect to nfs server started under heartbeat
through
virtual IP.

I have a very similar setup. 2 Redhat 9.0 boxes running DRBD - Network RAID
1 -
 and NFS Server +statd+portmap+fam under heartbeat 1.0.3

I have edited the default /etc/init.d/nfslock script to start rpc.statd
with
the option -n vitualIP so that when NFS server crashes and falls over to
the
secondary, I shouldn't have problems from clients complaining that the
statd
host changed.

However, like him, I got the same error when trying to mount an exported
directory from the NFS Server via the virtual IP of the 2-node heartbeat
cluster.
The error is: NFSPROC_NULL: RPC: Timed out

Running tcpdump on the primary node like so:
tcpdump -np -s 1600 udp port 2049
gives some interesting info, especially when I retry mounting by the
virtual
ip from the nfs client. It looks like the server accepts the connection on
the
virtual ip (i.e. eth0:0) but nfsd on port 2049 replies using the primary
interface ip (i.e. eth0). The client doesn't like the reply from different
host I guess therefore timing out.

Searching everywhere found few hints. FreeBSD's nfsd has a -h option to
specify host/ip to tie nfsd to, but Linux doesn't. This blows because AFAIK

drbd is strictly linux 2.x based.

I tried modifying /etc/ha.d/resources.d/IPaddr so that the ip is assigned
in
add_address() to eth0 statically instead of the eth#:# and also in
delete_address, and although I was able to mount now from the clients,
heartbeat stop doesn't seem to stop the services anymore and I see errors
reported in /var/log/ha-log about IPaddr error 1

Any help would be appreciated.

Best Regards,
Tim





----- End forwarded message -----



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
