Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44931 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433Ab3EMXeR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 19:34:17 -0400
Date: Mon, 13 May 2013 16:34:11 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Possible bug introduced by: NFS: Use server-recommended security
 flavor by default (NFSv3)?
Message-ID: <20130513233411.GB29406@blackbox.djwong.org>
References: <20130513203556.GA8049@blackbox.djwong.org>
 <C98A6B64-9648-4CBD-8E10-8C54B7DA98B6@oracle.com>
 <20130513212440.GB8049@blackbox.djwong.org>
 <6B5CEA91-77C1-4F2A-8A97-B01B9399EF85@oracle.com>
 <497CC2C4-E417-4BB9-B4FD-E737A23479E3@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <497CC2C4-E417-4BB9-B4FD-E737A23479E3@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 13, 2013 at 10:45:06PM +0000, Adamson, Dros wrote:
> 
> On May 13, 2013, at 5:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > 
> > On May 13, 2013, at 5:24 PM, "Darrick J. Wong" <darrick.wong@oracle.com> wrote:
> > 
> >> On Mon, May 13, 2013 at 04:41:01PM -0400, Chuck Lever wrote:
> >>> 
> >>> On May 13, 2013, at 4:35 PM, "Darrick J. Wong" <darrick.wong@oracle.com> wrote:
> >>> 
> >>>> Hi there,
> >>>> 
> >>>> I've a question about a recent nfs client commit
> >>>> (4580a92d44e2b21c2254fa5fef0f1bfb43c82318).
> >>>> 
> >>>> I have a kvm-based testing setup that netboots VMs over NFS, the client end of
> >>>> which seems to have broken somehow in 3.10-rc1.  The server's exports file
> >>>> looks like this:
> >>>> 
> >>>> /storage/mtr/x64	192.168.122.0/24(ro,sync,no_root_squash,no_subtree_check)
> >>>> 
> >>>> On the client end (inside the VM), the initrd runs the following command to
> >>>> try to mount the rootfs over NFS:
> >>>> 
> >>>> # mount -o nolock -o ro -o retrans=10 192.168.122.1:/storage/mtr/x64/ /root
> >>>> 
> >>>> (Note: This is the busybox mount command.)
> >>>> 
> >>>> The mount fails with -EINVAL; using rpcdebug to turn on all rpc/nfs debugging
> >>>> yields this in dmesg:
> >>>> 
> >>>> [   28.298869] --> nfs_init_server()
> >>>> [   28.299874] --> nfs_get_client(192.168.122.1,v3)
> >>>> [   28.300839] RPC:       looking up machine cred for service *
> >>>> [   28.301666] RPC:       set up xprt to 192.168.122.1 (port 2049) via tcp
> >>>> [   28.302713] RPC:       created transport ffff88007b64c000 with 65536 slots
> >>>> [   28.304263] RPC:       creating nfs client for 192.168.122.1 (xprt ffff88007b64c000)
> >>>> [   28.306791] RPC:       creating UNIX authenticator for client ffff8800379ac800
> >>>> [   28.308379] RPC:       new task initialized, procpid 250
> >>>> [   28.309427] RPC:       allocated task ffff88003785de00
> >>>> [   28.310427] RPC:     2 __rpc_execute flags=0x680
> >>>> [   28.311389] RPC:     2 call_start nfs3 proc NULL (sync)
> >>>> [   28.312507] RPC:     2 call_reserve (status 0)
> >>>> [   28.313456] RPC:     2 reserved req ffff8800379acc00 xid 0807e503
> >>>> [   28.314663] RPC:       wake_up_first(ffff88007b64c190 "xprt_sending")
> >>>> [   28.315928] RPC:     2 call_reserveresult (status 0)
> >>>> [   28.316958] RPC:     2 call_refresh (status 0)
> >>>> [   28.317908] RPC:     2 holding NULL cred ffffffff81a8ca40
> >>>> [   28.319496] RPC:     2 refreshing NULL cred ffffffff81a8ca40
> >>>> [   28.322685] RPC:     2 call_refreshresult (status 0)
> >>>> [   28.323584] RPC:     2 call_allocate (status 0)
> >>>> [   28.324422] RPC:     2 allocated buffer of size 96 at ffff88007b64d000
> >>>> [   28.325440] RPC:     2 call_bind (status 0)
> >>>> [   28.326159] RPC:     2 call_connect xprt ffff88007b64c000 is not connected
> >>>> [   28.327261] RPC:     2 xprt_connect xprt ffff88007b64c000 is not connected
> >>>> [   28.328267] RPC:     2 sleep_on(queue "xprt_pending" time 4294899378)
> >>>> [   28.330278] RPC:     2 added to queue ffff88007b64c258 "xprt_pending"
> >>>> [   28.332390] RPC:     2 setting alarm for 700 ms
> >>>> [   28.333979] RPC:       xs_connect scheduled xprt ffff88007b64c000
> >>>> [   28.336093] RPC:       xs_bind 0.0.0.0:785: ok (0)
> >>>> [   28.337671] RPC:       worker connecting xprt ffff88007b64c000 via tcp to 192.168.122.1 (port 2049)
> >>>> [   28.340639] RPC:     2 sync task going to sleep
> >>>> [   28.342523] RPC:       xs_tcp_state_change client ffff88007b64c000...
> >>>> [   28.344517] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
> >>>> [   28.346451] RPC:     2 __rpc_wake_up_task (now 4294899382)
> >>>> [   28.348203] RPC:     2 disabling timer
> >>>> [   28.349506] RPC:     2 removed from queue ffff88007b64c258 "xprt_pending"
> >>>> [   28.353656] RPC:       __rpc_wake_up_task done
> >>>> [   28.353669] RPC:     2 sync task resuming
> >>>> [   28.353670] RPC:     2 xprt_connect_status: retrying
> >>>> [   28.353671] RPC:     2 call_connect_status (status -11)
> >>>> [   28.353673] RPC:     2 call_transmit (status 0)
> >>>> [   28.353673] RPC:     2 xprt_prepare_transmit
> >>>> [   28.380891] RPC:     2 rpc_xdr_encode (status 0)
> >>>> [   28.381876] RPC:       ffff88007b64c000 connect status 115 connected 1 sock state 1
> >>>> [   28.386321] RPC:     2 marshaling NULL cred ffffffff81a8ca40
> >>>> [   28.387616] RPC:     2 using AUTH_NULL cred ffffffff81a8ca40 to wrap rpc data
> >>>> [   28.389654] RPC:     2 xprt_transmit(44)
> >>>> [   28.391105] RPC:       xs_tcp_send_request(44) = 44
> >>>> [   28.391968] RPC:       xs_tcp_data_ready...
> >>>> [   28.391970] RPC:       xs_tcp_data_recv started
> >>>> [   28.391971] RPC:       reading TCP record fragment of length 24
> >>>> [   28.391972] RPC:       reading XID (4 bytes)
> >>>> [   28.391974] RPC:       reading request with XID 0807e503
> >>>> [   28.391975] RPC:       reading CALL/REPLY flag (4 bytes)
> >>>> [   28.391976] RPC:       read reply XID 0807e503
> >>>> [   28.391977] RPC:       XID 0807e503 read 16 bytes
> >>>> [   28.391978] RPC:       xprt = ffff88007b64c000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
> >>>> [   28.391980] RPC:     2 xid 0807e503 complete (24 bytes received)
> >>>> [   28.391981] RPC:       xs_tcp_data_recv done
> >>>> [   28.411740] RPC:     2 xmit complete
> >>>> [   28.412933] RPC:       wake_up_first(ffff88007b64c190 "xprt_sending")
> >>>> [   28.414312] RPC:     2 call_status (status 24)
> >>>> [   28.417274] RPC:     2 call_decode (status 24)
> >>>> [   28.418798] RPC:     2 validating NULL cred ffffffff81a8ca40
> >>>> [   28.420611] RPC:     2 using AUTH_NULL cred ffffffff81a8ca40 to unwrap rpc data
> >>>> [   28.423049] RPC:     2 call_decode result 0
> >>>> [   28.424544] RPC:     2 return 0, status 0
> >>>> [   28.425971] RPC:     2 release task
> >>>> [   28.427287] RPC:       freeing buffer of size 96 at ffff88007b64d000
> >>>> [   28.429270] RPC:     2 release request ffff8800379acc00
> >>>> [   28.430915] RPC:       wake_up_first(ffff88007b64c320 "xprt_backlog")
> >>>> [   28.432894] RPC:       rpc_release_client(ffff8800379ac800)
> >>>> [   28.434631] RPC:     2 freeing task
> >>>> [   28.435881] RPC:       creating nfs client for 192.168.122.1 (xprt ffff88007b64c000)
> >>>> [   28.438469] RPC:       Couldn't create auth handle (flavor 8)
> >>>> [   28.487427] RPC:       __rpc_clone_client: returned error -22
> >>>> [   28.489314] nfs_init_server_rpcclient: couldn't create rpc_client!
> >>>> [   28.491316] --> nfs_put_client({1})
> >>>> [   28.492597] --> nfs_free_client(3)
> >>>> [   28.493765] RPC:       shutting down nfs client for 192.168.122.1
> >>>> [   28.495703] RPC:       rpc_release_client(ffff8800379ac800)
> >>>> [   28.497492] RPC:       destroying UNIX authenticator ffffffff81a8cae0
> >>>> [   28.499473] RPC:       destroying nfs client for 192.168.122.1
> >>>> [   28.501329] RPC:       destroying transport ffff88007b64c000
> >>>> [   28.503042] RPC:       xs_destroy xprt ffff88007b64c000
> >>>> [   28.504776] RPC:       xs_close xprt ffff88007b64c000
> >>>> [   28.506572] RPC:       disconnected transport ffff88007b64c000
> >>>> [   28.508885] <-- nfs_free_client()
> >>>> [   28.510585] <-- nfs_init_server() = xerror -22
> >>>> [   28.512353] --> nfs_free_server()
> >>>> [   28.513692] <-- nfs_free_server()
> >>>> mount: Invalid argument
> >>>> 
> >>>> It looks as though it's trying to create a RPC auth somethingorother (I'm no
> >>>> NFS expert) of type RPC_AUTH_MAXFLAVOR, which afaict isn't a real auth flavor.
> >>> 
> >>> RPC_AUTH_MAXFLAVOR means no "sec=" was specified on the mount command line.
> >>> Some part of this logic is allowing that flavor to leak past the initial
> >>> mount code.
> >> 
> >> <nod> I tried mounting with -o sec=sys but it didn't change the outcome...
> >> 
> >>>> The creation fails, and therefore the mount also fails.  I noticed, however, if
> >>>> I revert the first stanza of the patch so that "data->auth_flavors[0] =
> >>>> RPC_AUTH_UNIX;", the mount works fine again.  After putting that back, I read
> >>>> the commit message attached to this patch and changed exports to read as
> >>>> follows:
> >>>> 
> >>>> /storage/mtr/x64	192.168.122.0/24(ro,sync,no_root_squash,no_subtree_check,sec=sys)
> >>>> 
> >>>> and restarted the nfs server.  Unfortunately, even with this sec=sys bit tacked
> >>>> on, I still see the message "Couldn't create auth handle (flavor 8)".
> >>>> 
> >>>> Note: This is an initramfs environment, there's no statd running.  There
> >>>> doesn't seem to be a portmapper either.
> >>>> 
> >>>> So, um... help?  I'm not sure what's going on here -- is this a bug in the
> >>>> kernel, or something messed up with the nfsd config?  The host is 3.9, the VM
> >>>> client is 3.10.
> >>> 
> >>> Darrick, exactly which kernel is running in your VM?
> >> 
> >> HEAD is 1f638766ffcd9f08209afcabb3e2df961552fe18 from Linus' tree.
> > 
> > And that does have Dros' fix to this logic:
> > 
> >  commit d497ab97 "NFSv3: match sec= flavor against server list"
> 
> Darrick,
> 
> Can we have some more of the rpcdebug output? I'm looking for output from '-m nfs -s mount' that looks like:
> 
> NFS: MNTPATH: '/export/krb5'
> NFS: sending MNT request for server:/export/krb5
> NFS: received 1 auth flavors
> NFS:   auth flavor[0]: 390003
> NFS: MNT request succeeded
> NFS: using auth flavor 390003
> 
> And the last line "using auth flavor ..." should tell us if d497ab97 is the culprit.

Aha!

If I try mounting with mount.nfs from nfs-common 1:1.2.5-3ubuntu3.1, I actually
do see some NFS: debugging output:

[  403.346811] NFS: nfs mount opts='addr=192.168.122.1,vers=3,proto=tcp,mountvers=3,mountproto=udp,mountport=48196'
[  403.354471] NFS:   parsing nfs mount option 'addr=192.168.122.1'
[  403.358281] NFS:   parsing nfs mount option 'vers=3'
[  403.360960] NFS:   parsing nfs mount option 'proto=tcp'
[  403.362619] NFS:   parsing nfs mount option 'mountvers=3'
[  403.364510] NFS:   parsing nfs mount option 'mountproto=udp'
[  403.366279] NFS:   parsing nfs mount option 'mountport=48196'
[  403.368102] NFS: MNTPATH: '/storage/mtr/x64/'
[  403.369258] NFS: sending MNT request for 192.168.122.1:/storage/mtr/x64/
[  403.374583] NFS: received 1 auth flavors
[  403.375932] NFS:   auth flavor[0]: 1
[  403.378708] NFS: MNT request succeeded
[  403.379368] NFS: using auth flavor 1

and the mount succeeds.  However, the Ubuntu initramfs uses the klibc
'nfsmount' program as a mount.nfs stand-in.  This `nfsmount' comes from
klibc-utils 1.5.25-1ubuntu2, and mount attempts with this program always fail.

I caught nfsmount making this call (via strace):
mount("192.168.122.1:/storage/home/djwong/cdev/work/", "/djwong", "nfs", 0, "\6")

Curiously, the last parameter is always "\6" no matter what mount options I
pass to the program.

Regular mount.nfs succeeds with this:
mount("192.168.122.1:/storage/home/djwong/cdev/work/", "/djwong", "nfs", 0, "addr=192.168.122.1,vers=3,proto=tcp,mountvers=3,mountproto=udp,mountport=48196")

Hope this helps a bit...

--D
