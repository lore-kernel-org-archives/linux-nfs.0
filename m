Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51378 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933694AbbLQWRg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2015 17:17:36 -0500
Date: Thu, 17 Dec 2015 17:17:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Add notifier blocks to close transport sockets when
 an ip address is deleted
Message-ID: <20151217221735.GD16808@fieldses.org>
References: <1449870360-23319-1-git-send-email-smayhew@redhat.com>
 <20151217195708.GA16808@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151217195708.GA16808@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 17, 2015 at 02:57:08PM -0500, J. Bruce Fields wrote:
> On Fri, Dec 11, 2015 at 04:45:57PM -0500, Scott Mayhew wrote:
> > A somewhat common configuration for highly available NFS v3 is to have nfsd and
> > lockd running at all times on the cluster nodes, and move the floating ip,
> > export configuration, and exported filesystem from one node to another when a
> > service failover or relocation occurs.
> > 
> > A problem arises in this sort of configuration though when an NFS service is
> > moved to another node and then moved back to the original node 'too quickly'
> > (i.e. before the original transport socket is closed on the first node).  When
> > this occurs, clients can experience delays that can last almost 15 minutes (2 *
> > svc_conn_age_period + time spent waiting in FIN_WAIT_1).  What happens is that
> > once the client reconnects to the original socket, the sequence numbers no
> > longer match up and bedlam ensues.
> >  
> > This isn't a new phenomenon -- slide 16 of this old presentation illustrates
> > the same scenario:
> >  
> > http://www.nfsv4bat.org/Documents/ConnectAThon/1996/nfstcp.pdf
> >  
> > One historical workaround was to set timeo=1 in the client's mount options.  The
> > reason the workaround worked is because once the client reconnects to the
> > original transport socket and the data stops moving,
> > we would start retransmitting at the RPC layer.  With the timeout set to 1/10 of
> > a second instead of the normal 60 seconds, the client's transport socket's send
> > buffer *much* more quickly, and once it filled up
> > there would a very good chance that an incomplete send would occur (from the
> > standpoint of the RPC layer -- at the network layer both sides are just spraying
> > ACKs at each other as fast as possible).  Once that happens, we would wind up
> > setting XPRT_CLOSE_WAIT in the client's rpc_xprt->state field in
> > xs_tcp_release_xprt() and on the next transmit the client would try to close the
> > connection.  Actually the FIN would get ignored by the server, again because the
> > sequence numbers were out of whack, so the client would wait for the FIN timeout
> > to expire, after which it would delete the socket, and upon receipt of the next
> > packet from the server to that port the client the client would respond with a
> > RST and things finally go back to normal.
> >  
> > That workaround used to work up until commit a9a6b52 (sunrpc: Dont start the
> > retransmission timer when out of socket space).  Now the client just waits for
> > its send buffer to empty out, which isn't going to happen in this scenario... so
> > we're back to waiting for the server's svc_serv->sv_temptimer aka
> > svc_age_temp_xprts() to do its thing.
> > 
> > These patches try to help that situation.  The first patch adds a function to
> > close temporary transports whose xpt_local matches the address passed in
> > server_addr immediately instead of waiting for them to be closed by the
> > svc_serv->sv_temptimer function.  The idea here is that if the ip address was
> > yanked out from under the service, then those transports are doomed and there's
> > no point in waiting up to 12 minutes to start cleaning them up.  The second
> > patch adds notifier_blocks (one for IPv4 and one for IPv6) to call that 
> > function to nfsd.  The third patch does the same thing, but for lockd.
> > 
> > I've been testing these patches on a RHEL 6 rgmanager cluster as well as a
> > Fedora 23 pacemaker cluster.  Note that the resource agents in pacemaker do not
> > behave the way I initially described... the pacemaker resource agents actually
> > do a full tear-down & bring up of the nfsd's as part of a service relocation, so
> > I hacked them up to behave like the older rgmanager agents in order to test.  I
> > tested with cthon and xfstests while moving the NFS service from one node to the
> > other every 60 seconds.  I also did more basic testing like taking & holding a
> > lock using the flock command from util-linux and making sure that the client was
> > able to reclaim the lock as I moved the service back and forth among the cluster
> > nodes.
> > 
> > For this to be effective, the clients still need to mount with a lower timeout,
> > but it doesn't need to be as aggressive as 1/10 of a second.
> 
> That's just to prevent a file operation hanging too long in the case
> that nfsd or ip shutdown prevents the client getting a reply?
> 
> > Also, for all this to work when the cluster nodes are running a firewall, it's
> > necessary to add a rule to trigger a RST.  The rule would need to be after the
> > rule that allows new NFS connections and before the catch-all rule that rejects
> > everyting else with ICMP-HOST-PROHIBITED.  For a Fedora server running
> > firewalld, the following commands accomplish that:
> > 
> > firewall-cmd --direct --add-passthrough ipv4 -A IN_FedoraServer_allow \
> > 	-m tcp -p tcp --dport 2049 -j REJECT --reject-with tcp-reset
> > firewall-cmd --runtime-to-permanent
> 
> To make sure I understand: so in the absence of the firewall, the
> client's packets arrive at a server that doesn't see them as belonging
> to any connection, so it replies with a RST.  In the presence of the
> firewall, the packets are rejected before they get to that point, so
> there's no RST, so we need this rule to trigger the RST instead.  Is
> that right?

By the way it might be nice to capture this in the kernel source
someplace.   Maybe just drop some version of the above text in a new
file named Documentation/filesystems/nfs/nfs-server-ha.txt or something
similar?

Anyway, the patches look OK to me.  I'll queue them up for 4.5 if
there's no objections.

--b.

--b.
