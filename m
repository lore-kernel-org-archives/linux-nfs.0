From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Thu, 3 Aug 2006 14:14:04 +1000
Message-ID: <17617.30732.643539.353696@cse.unsw.edu.au>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8Ub5-0007XS-Hw
	for nfs@lists.sourceforge.net; Wed, 02 Aug 2006 21:14:11 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8Ub5-0004qP-5U
	for nfs@lists.sourceforge.net; Wed, 02 Aug 2006 21:14:12 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: message from Wendy Cheng on Monday July 31
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Thanks for these.

First note:  it helps a lot if the Subject line for each patch
contains a distinctive short description of what the patch does.
Rather than just "NLM lock failover" three times, maybe
  Add nlm_lock file to nfsd fs to allow selective unlocked based on server IP
  Add nlm_set_ip_grace file to allow selective setting of grace time
  Use IP address rather than hostname in SM_{UN,}MON calls to statd

Or something like that.

> 
> PATCH 1/3
> ---------
> Add a new admin interface into current nfsd procfs filesystem to trigger
> NLM lock releasing logic. The command is invoked by echoing the server
> IP V4 address (in standard dot notation) into /proc/fs/nfsd/nlm_unlock
> file as:
> 
> shell> cd /prod/fs/nfsd
> shell> echo 10.10.1.1 > nlm_unlock
> 

This patch makes an assumption that any given filehandle will only arrive at
one particular interface - never more.  This is implicit in the fact
that f_iaddr is stored in 'struct nlm_file' which is indexed by
filehandle.

In the case where you are intending to support active-active failover
this is should be the case, but obviously configuration errors are
possible.

I think what I would like is that if requests arrive at two (or more)
different interfaces for the one file, then f_iaddr is cleared and some
flag is set.
When an IP is written to nlm_unlock, if the flag is set, then a
warning message is printer 
  Note: some files access via multiple interfaces will not be
  unlocked.

A consequence of this is that you cannot have a virtual server with
two (or more interfaces).  Is this likely to be a problem?
e.g. if you have 4 physical interfaces on your server, might you want
to bind a different IP to each for each virtual server?
If you did, then my change above would mean that you couldn't do
failover, and we might need to look at other options...

Possibly (and maybe this is more work than is justified), lockd can
monitor interface usage and deduce interface pools based on seeing the
same filehandle on multiple interfaces.  Then when an unlock request
arrives on nlm_unlock, lockd would require all interfaces that touched
a file to be 'unlocked' before actually dropping the locks on the
file.

As you can probably tell I was "thinking out loud" there and it may
not be particularly coherent or cohesive.   

Do you have any thoughts on this issues?


> PATCH 2/3
> ---------
> Add take-over server counter-part command into nfsd procfs interface to
> allow selectively setting of per (virtual) ip (lockd) grace period. The
> grace period setting follows current system-wide grace period rule and
> default. It is also invoked by echoing the server IP V4 address (in dot
> notation) into /proc/fs/nfsd/nlm_set_ip_grace file:
> 
> shell> cd /proc/fs/nfsd
> shell> echo 10.10.1.1 > nlm_set_ip_grace
> 

I think nlm_ip_mutex should be a spinlock, and I don't think you
should need to hold the lock in __nlm_servs_gc, as you have already
disconnected these entries from the global list.

+extern unsigned long set_grace_period(void); /* see fs/lockd/svc.c */

That should go in a header file.

+			switch (passthru_check) {
+				case NLMSVC_FO_PASSTHRU:
+					break;
+				case NLMSVC_FO_RECLAIM:
+					if (argp->reclaim) break;
+				default:
+					return nlm_lck_denied_grace_period;
+			}

I'd rather you spelt out
				case NLMSVC_FO_BLOCK_ANY:
rather than used 'default:' - it makes the code more readable.

and surely you should check for NLMSVC_FO_PASSTHRU before calling
nlmsvc_fo_check ???

It seems to me that it would be clearer not to put the nlmsvc_fo_check
call inside nlm*svc_retrieve_args, but rather to define e.g.
  nlmsvc_is_grace_period(rqstp)
which checks nlmsvc_grace_period and the list of IPs, and then replace
every
	if (nlmsvc_grace_period) {
		resp->status = nlm_lck_denied_grace_period;
		return rpc_success;
	}
with
	if (nlmsvc_is_grace_period(rqstp)) {
		resp->status = nlm_lck_denied_grace_period;
		return rpc_success;
	}
and every 
	if (nlmsvc_grace_period && !argp->reclaim) {
		resp->status = nlm_lck_denied_grace_period;
		return rpc_success;
	}
with
	if (!argp->reclaim && nlmsvc_is_grace_period(rqstp)) {
		resp->status = nlm_lck_denied_grace_period;
		return rpc_success;
	}

Does that seem reasonable to you?



> PATCH 3/3
> ---------
> This kernel patch adds a new field into struct nlm_host that holds the
> server IP address. Upon SM_MON and SM_UNMON procedure calls, the IP (in
> standard V4 dot notation) is placed as the "my_name" string and passed
> to local statd daemon. This enables ha-callout program ("man rpc.statd"
> for details) to receive the IP address of the server that has received
> the client's request. Before this change, my_name string is universally
> set to system_utsname.nodename.
> 
> The user mode HA implementation is expected to:
> 1. Specify a user mode ha-calloupt program (rpc.statd -H) for receiving
>    client monitored states.
> 2. Based on info passed by ha-callout, individual state-directory should
>    be created and can be read from take-over server.
> 3. Upon failover, on take-over server, send out notification to nfs
>    client via (rpc.statd -n server_ip -P individual_state_directory -N)
>    command.

Was it necessary to rename "s_server" to "s_where"?  Could you not
have just introduced "s_server_ip"???

And if you really want s_where, then I would like some #defines and
make

+	if (server) 
+		host->h_where = 1;
+	else
+		host->h_where = 0;

something like
	host->where = server ? ON_SERVER : ON_CLIENT


(reading some more) In fact, you don't need h_where at all.  Just
change h_server to be the IP address, and then use e.g.
-	args.proto= (host->h_proto<<1) | host->h_server;
+	args.serv = host->h_server;
+	args.proto= (host->h_proto<<1) | (host->h_server?1:0)

(or host->server!=0  or !!host->server - whatever takes your fancy).

@@ -142,7 +142,7 @@ out_err:
 static u32 *
 xdr_encode_common(struct rpc_rqst *rqstp, u32 *p, struct nsm_args *argp)
 {
-	char	buffer[20];
+	char	buffer[100]; 

This looks like it should really be a separate patch, and should
probably be __NEW_UTS_LEN+1 rather than 100.



But I worry about other people who might be using ha-callout already
and expecting a host name there.  We are making a non-optional
user-visible change here.  Is it really a safe thing to do?


Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
