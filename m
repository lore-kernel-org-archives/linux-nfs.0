Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.wiktel.com ([69.89.207.151]:50368 "EHLO smtp1.wiktel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbcCKJov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Mar 2016 04:44:51 -0500
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        trond.myklebust@primarydata.com
References: <56BFE55D.1010509@wiktel.com> <56DF067F.4090606@wiktel.com>
 <56E092C3.6030508@Netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Richard Laager <rlaager@wiktel.com>
Message-ID: <56E2938C.5040601@wiktel.com>
Date: Fri, 11 Mar 2016 03:44:44 -0600
MIME-Version: 1.0
In-Reply-To: <56E092C3.6030508@Netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/09/2016 03:16 PM, Anna Schumaker wrote:
> I'm looking into this, but I'm not yet sure of what the client is doing.  Your packet trace makes it look like we do recover, although I don't know why it takes more than one RST packet.
> 
> Is this easy for you to reproduce?  It would be great if you can send me debugging statements from the client.  You can enable them with the command:  `rpcdebug -m rpc -s trans call` and then rerun the failover.  Client messages should show up in dmesg.

sudo rpcdebug -m rpc -s trans call
sudo mount /mnt/mail

2016-03-11T03:22:04.961449-06:00 imap1 kernel: [  159.769021] RPC:       set up xprt to 10.20.0.30 (port 59274) via tcp
2016-03-11T03:22:04.961462-06:00 imap1 kernel: [  159.769031] RPC:       creating mount client for 10.20.0.30 (xprt ffff88003cfe1800)
2016-03-11T03:22:04.961464-06:00 imap1 kernel: [  159.769046] RPC:    94 call_start mount3 proc NULL (sync)
2016-03-11T03:22:04.961465-06:00 imap1 kernel: [  159.769047] RPC:    94 call_reserve (status 0)
2016-03-11T03:22:04.961466-06:00 imap1 kernel: [  159.769051] RPC:    94 call_reserveresult (status 0)
2016-03-11T03:22:04.961467-06:00 imap1 kernel: [  159.769052] RPC:    94 call_refresh (status 0)
2016-03-11T03:22:04.961468-06:00 imap1 kernel: [  159.769054] RPC:    94 call_refreshresult (status 0)
2016-03-11T03:22:04.961469-06:00 imap1 kernel: [  159.769055] RPC:    94 call_allocate (status 0)
2016-03-11T03:22:04.961470-06:00 imap1 kernel: [  159.769057] RPC:    94 call_bind (status 0)
2016-03-11T03:22:04.961471-06:00 imap1 kernel: [  159.769058] RPC:    94 call_connect xprt ffff88003cfe1800 is not connected
2016-03-11T03:22:04.961471-06:00 imap1 kernel: [  159.769061] RPC:       xs_connect scheduled xprt ffff88003cfe1800
2016-03-11T03:22:04.961473-06:00 imap1 kernel: [  159.769075] RPC:       xs_bind 0.0.0.0:845: ok (0)
2016-03-11T03:22:04.961474-06:00 imap1 kernel: [  159.769077] RPC:       worker connecting xprt ffff88003cfe1800 via tcp to 10.20.0.30 (port 59274)
2016-03-11T03:22:04.961475-06:00 imap1 kernel: [  159.769099] RPC:       ffff88003cfe1800 connect status 115 connected 0 sock state 2
2016-03-11T03:22:04.961476-06:00 imap1 kernel: [  159.769321] RPC:       xs_tcp_state_change client ffff88003cfe1800...
2016-03-11T03:22:04.961476-06:00 imap1 kernel: [  159.769323] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
2016-03-11T03:22:04.961477-06:00 imap1 kernel: [  159.769350] RPC:    94 call_connect_status (status -11)
2016-03-11T03:22:04.961479-06:00 imap1 kernel: [  159.769352] RPC:    94 call_timeout (minor)
2016-03-11T03:22:04.961480-06:00 imap1 kernel: [  159.769353] RPC:    94 call_bind (status 0)
2016-03-11T03:22:04.961481-06:00 imap1 kernel: [  159.769354] RPC:    94 call_connect xprt ffff88003cfe1800 is connected
2016-03-11T03:22:04.961481-06:00 imap1 kernel: [  159.769356] RPC:    94 call_transmit (status 0)
2016-03-11T03:22:04.961482-06:00 imap1 kernel: [  159.769357] RPC:    94 rpc_xdr_encode (status 0)
2016-03-11T03:22:04.961483-06:00 imap1 kernel: [  159.769370] RPC:       xs_tcp_send_request(44) = 0
2016-03-11T03:22:04.961484-06:00 imap1 kernel: [  159.769749] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:04.961485-06:00 imap1 kernel: [  159.769772] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:04.961486-06:00 imap1 kernel: [  159.769774] RPC:       reading TCP record fragment of length 24
2016-03-11T03:22:04.961487-06:00 imap1 kernel: [  159.769775] RPC:       reading XID (4 bytes)
2016-03-11T03:22:04.961488-06:00 imap1 kernel: [  159.769777] RPC:       reading request with XID 38e59d54
2016-03-11T03:22:04.961490-06:00 imap1 kernel: [  159.769778] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:04.961491-06:00 imap1 kernel: [  159.769779] RPC:       read reply XID 38e59d54
2016-03-11T03:22:04.961492-06:00 imap1 kernel: [  159.769781] RPC:       XID 38e59d54 read 16 bytes
2016-03-11T03:22:04.961493-06:00 imap1 kernel: [  159.769783] RPC:       xprt = ffff88003cfe1800, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
2016-03-11T03:22:04.961494-06:00 imap1 kernel: [  159.769787] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:04.961494-06:00 imap1 kernel: [  159.769792] RPC:    94 call_status (status 24)
2016-03-11T03:22:04.961495-06:00 imap1 kernel: [  159.769793] RPC:    94 call_decode (status 24)
2016-03-11T03:22:04.961496-06:00 imap1 kernel: [  159.769795] RPC:    94 call_decode result 0
2016-03-11T03:22:04.961497-06:00 imap1 kernel: [  159.769798] RPC:       rpc_release_client(ffff88003b53ee00)
2016-03-11T03:22:04.961498-06:00 imap1 kernel: [  159.769801] RPC:    95 call_start mount3 proc MOUNT (sync)
2016-03-11T03:22:04.961499-06:00 imap1 kernel: [  159.769802] RPC:    95 call_reserve (status 0)
2016-03-11T03:22:04.961500-06:00 imap1 kernel: [  159.769803] RPC:    95 call_reserveresult (status 0)
2016-03-11T03:22:04.961501-06:00 imap1 kernel: [  159.769804] RPC:    95 call_refresh (status 0)
2016-03-11T03:22:04.961502-06:00 imap1 kernel: [  159.769807] RPC:    95 call_refreshresult (status 0)
2016-03-11T03:22:04.961503-06:00 imap1 kernel: [  159.769808] RPC:    95 call_allocate (status 0)
2016-03-11T03:22:04.961503-06:00 imap1 kernel: [  159.769809] RPC:    95 call_bind (status 0)
2016-03-11T03:22:04.961504-06:00 imap1 kernel: [  159.769811] RPC:    95 call_connect xprt ffff88003cfe1800 is connected
2016-03-11T03:22:04.961505-06:00 imap1 kernel: [  159.769812] RPC:    95 call_transmit (status 0)
2016-03-11T03:22:04.961506-06:00 imap1 kernel: [  159.769813] RPC:    95 rpc_xdr_encode (status 0)
2016-03-11T03:22:04.961507-06:00 imap1 kernel: [  159.769830] RPC:       xs_tcp_send_request(100) = 0
2016-03-11T03:22:04.965480-06:00 imap1 kernel: [  159.774107] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:04.965488-06:00 imap1 kernel: [  159.774118] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:04.965489-06:00 imap1 kernel: [  159.774120] RPC:       reading TCP record fragment of length 72
2016-03-11T03:22:04.965490-06:00 imap1 kernel: [  159.774121] RPC:       reading XID (4 bytes)
2016-03-11T03:22:04.965490-06:00 imap1 kernel: [  159.774123] RPC:       reading reply for XID 39e59d54
2016-03-11T03:22:04.965491-06:00 imap1 kernel: [  159.774124] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:04.965492-06:00 imap1 kernel: [  159.774125] RPC:       read reply XID 39e59d54
2016-03-11T03:22:04.965492-06:00 imap1 kernel: [  159.774127] RPC:       XID 39e59d54 read 64 bytes
2016-03-11T03:22:04.965493-06:00 imap1 kernel: [  159.774129] RPC:       xprt = ffff88003cfe1800, tcp_copied = 72, tcp_offset = 72, tcp_reclen = 72
2016-03-11T03:22:04.965494-06:00 imap1 kernel: [  159.774134] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:04.965495-06:00 imap1 kernel: [  159.774141] RPC:    95 call_status (status 72)
2016-03-11T03:22:04.965495-06:00 imap1 kernel: [  159.774143] RPC:    95 call_decode (status 72)
2016-03-11T03:22:04.965496-06:00 imap1 kernel: [  159.774146] RPC:    95 call_decode result 0
2016-03-11T03:22:04.965497-06:00 imap1 kernel: [  159.774150] RPC:       rpc_release_client(ffff88003b53ee00)
2016-03-11T03:22:04.965497-06:00 imap1 kernel: [  159.774153] RPC:       shutting down mount client for 10.20.0.30
2016-03-11T03:22:04.965498-06:00 imap1 kernel: [  159.774154] RPC:       rpc_release_client(ffff88003b53ee00)
2016-03-11T03:22:04.965499-06:00 imap1 kernel: [  159.774157] RPC:       destroying mount client for 10.20.0.30
2016-03-11T03:22:04.965499-06:00 imap1 kernel: [  159.774170] RPC:       xs_destroy xprt ffff88003cfe1800
2016-03-11T03:22:04.965500-06:00 imap1 kernel: [  159.774171] RPC:       xs_close xprt ffff88003cfe1800
2016-03-11T03:22:04.965501-06:00 imap1 kernel: [  159.774190] RPC:       xs_tcp_state_change client ffff88003cfe1800...
2016-03-11T03:22:04.965501-06:00 imap1 kernel: [  159.774192] RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
2016-03-11T03:22:04.965502-06:00 imap1 kernel: [  159.774221] RPC:       set up xprt to 10.20.0.30 (autobind) via tcp
2016-03-11T03:22:04.965503-06:00 imap1 kernel: [  159.774229] RPC:       creating nfs client for 10.20.0.30 (xprt ffff88003cfe4000)
2016-03-11T03:22:04.965504-06:00 imap1 kernel: [  159.774270] RPC:    96 call_start nfs3 proc NULL (sync)
2016-03-11T03:22:04.965504-06:00 imap1 kernel: [  159.774272] RPC:    96 call_reserve (status 0)
2016-03-11T03:22:04.965505-06:00 imap1 kernel: [  159.774274] RPC:    96 call_reserveresult (status 0)
2016-03-11T03:22:04.965506-06:00 imap1 kernel: [  159.774302] RPC:    96 call_refresh (status 0)
2016-03-11T03:22:04.965506-06:00 imap1 kernel: [  159.774304] RPC:    96 call_refreshresult (status 0)
2016-03-11T03:22:04.965507-06:00 imap1 kernel: [  159.774305] RPC:    96 call_allocate (status 0)
2016-03-11T03:22:04.965508-06:00 imap1 kernel: [  159.774307] RPC:    96 call_bind (status 0)
2016-03-11T03:22:04.965508-06:00 imap1 kernel: [  159.774312] RPC:       set up xprt to 10.20.0.30 (port 111) via tcp
2016-03-11T03:22:04.965509-06:00 imap1 kernel: [  159.774318] RPC:       creating rpcbind client for 10.20.0.30 (xprt ffff88003cfe0800)
2016-03-11T03:22:04.965510-06:00 imap1 kernel: [  159.774329] RPC:       rpc_release_client(ffff88003b53e200)
2016-03-11T03:22:04.965510-06:00 imap1 kernel: [  159.774334] RPC:    97 call_start rpcbind2 proc GETPORT (async)
2016-03-11T03:22:04.965511-06:00 imap1 kernel: [  159.774335] RPC:    97 call_reserve (status 0)
2016-03-11T03:22:04.965512-06:00 imap1 kernel: [  159.774336] RPC:    97 call_reserveresult (status 0)
2016-03-11T03:22:04.965513-06:00 imap1 kernel: [  159.774337] RPC:    97 call_refresh (status 0)
2016-03-11T03:22:04.965513-06:00 imap1 kernel: [  159.774339] RPC:    97 call_refreshresult (status 0)
2016-03-11T03:22:04.965514-06:00 imap1 kernel: [  159.774340] RPC:    97 call_allocate (status 0)
2016-03-11T03:22:04.965515-06:00 imap1 kernel: [  159.774341] RPC:    97 call_bind (status 0)
2016-03-11T03:22:04.965515-06:00 imap1 kernel: [  159.774343] RPC:    97 call_connect xprt ffff88003cfe0800 is not connected
2016-03-11T03:22:04.965516-06:00 imap1 kernel: [  159.774345] RPC:       xs_connect scheduled xprt ffff88003cfe0800
2016-03-11T03:22:04.965526-06:00 imap1 kernel: [  159.774350] RPC:       worker connecting xprt ffff88003cfe0800 via tcp to 10.20.0.30 (port 111)
2016-03-11T03:22:04.965527-06:00 imap1 kernel: [  159.774372] RPC:       ffff88003cfe0800 connect status 115 connected 0 sock state 2
2016-03-11T03:22:04.969445-06:00 imap1 kernel: [  159.778489] RPC:       xs_tcp_state_change client ffff88003cfe0800...
2016-03-11T03:22:04.969452-06:00 imap1 kernel: [  159.778492] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
2016-03-11T03:22:04.969454-06:00 imap1 kernel: [  159.778537] RPC:    97 call_connect_status (status -11)
2016-03-11T03:22:04.969454-06:00 imap1 kernel: [  159.778539] RPC:    97 call_timeout (minor)
2016-03-11T03:22:04.969455-06:00 imap1 kernel: [  159.778540] RPC:    97 call_bind (status 0)
2016-03-11T03:22:04.969456-06:00 imap1 kernel: [  159.778541] RPC:    97 call_connect xprt ffff88003cfe0800 is connected
2016-03-11T03:22:04.969457-06:00 imap1 kernel: [  159.778543] RPC:    97 call_transmit (status 0)
2016-03-11T03:22:04.969457-06:00 imap1 kernel: [  159.778544] RPC:    97 rpc_xdr_encode (status 0)
2016-03-11T03:22:04.969458-06:00 imap1 kernel: [  159.778560] RPC:       xs_tcp_send_request(88) = 0
2016-03-11T03:22:04.988685-06:00 imap1 kernel: [  159.799227] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:04.988700-06:00 imap1 kernel: [  159.799265] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:04.988702-06:00 imap1 kernel: [  159.799267] RPC:       reading TCP record fragment of length 28
2016-03-11T03:22:04.988703-06:00 imap1 kernel: [  159.799268] RPC:       reading XID (4 bytes)
2016-03-11T03:22:04.988704-06:00 imap1 kernel: [  159.799270] RPC:       reading request with XID ec7eb156
2016-03-11T03:22:04.988704-06:00 imap1 kernel: [  159.799271] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:04.988706-06:00 imap1 kernel: [  159.799272] RPC:       read reply XID ec7eb156
2016-03-11T03:22:04.988706-06:00 imap1 kernel: [  159.799274] RPC:       XID ec7eb156 read 20 bytes
2016-03-11T03:22:04.988707-06:00 imap1 kernel: [  159.799275] RPC:       xprt = ffff88003cfe0800, tcp_copied = 28, tcp_offset = 28, tcp_reclen = 28
2016-03-11T03:22:04.988708-06:00 imap1 kernel: [  159.799277] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:04.988708-06:00 imap1 kernel: [  159.799280] RPC:    97 call_status (status 28)
2016-03-11T03:22:04.988709-06:00 imap1 kernel: [  159.799281] RPC:    97 call_decode (status 28)
2016-03-11T03:22:04.988710-06:00 imap1 kernel: [  159.799283] RPC:    97 call_decode result 0
2016-03-11T03:22:04.988711-06:00 imap1 kernel: [  159.799285] RPC:       setting port for xprt ffff88003cfe4000 to 2049
2016-03-11T03:22:04.988712-06:00 imap1 kernel: [  159.799289] RPC:       rpc_release_client(ffff88003b53e200)
2016-03-11T03:22:04.988712-06:00 imap1 kernel: [  159.799290] RPC:       destroying rpcbind client for 10.20.0.30
2016-03-11T03:22:04.988713-06:00 imap1 kernel: [  159.799305] RPC:       xs_destroy xprt ffff88003cfe0800
2016-03-11T03:22:04.988714-06:00 imap1 kernel: [  159.799307] RPC:       xs_close xprt ffff88003cfe0800
2016-03-11T03:22:04.988715-06:00 imap1 kernel: [  159.799320] RPC:       xs_tcp_state_change client ffff88003cfe0800...
2016-03-11T03:22:04.988716-06:00 imap1 kernel: [  159.799321] RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
2016-03-11T03:22:04.989445-06:00 imap1 kernel: [  159.799598] RPC:    96 call_bind_status (status 0)
2016-03-11T03:22:04.989450-06:00 imap1 kernel: [  159.799601] RPC:    96 call_connect xprt ffff88003cfe4000 is not connected
2016-03-11T03:22:04.989451-06:00 imap1 kernel: [  159.799603] RPC:       xs_connect scheduled xprt ffff88003cfe4000
2016-03-11T03:22:04.989452-06:00 imap1 kernel: [  159.799615] RPC:       xs_bind 0.0.0.0:960: ok (0)
2016-03-11T03:22:04.989453-06:00 imap1 kernel: [  159.799617] RPC:       worker connecting xprt ffff88003cfe4000 via tcp to 10.20.0.30 (port 2049)
2016-03-11T03:22:04.989453-06:00 imap1 kernel: [  159.799645] RPC:       ffff88003cfe4000 connect status 115 connected 0 sock state 2
2016-03-11T03:22:05.007935-06:00 imap1 kernel: [  159.818487] RPC:       xs_tcp_state_change client ffff88003cfe4000...
2016-03-11T03:22:05.007943-06:00 imap1 kernel: [  159.818502] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
2016-03-11T03:22:05.007945-06:00 imap1 kernel: [  159.818585] RPC:    96 call_connect_status (status -11)
2016-03-11T03:22:05.007946-06:00 imap1 kernel: [  159.818589] RPC:    96 call_timeout (minor)
2016-03-11T03:22:05.007950-06:00 imap1 kernel: [  159.818592] RPC:    96 call_bind (status 0)
2016-03-11T03:22:05.007951-06:00 imap1 kernel: [  159.818593] RPC:    96 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:22:05.007953-06:00 imap1 kernel: [  159.818595] RPC:    96 call_transmit (status 0)
2016-03-11T03:22:05.007953-06:00 imap1 kernel: [  159.818596] RPC:    96 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.009461-06:00 imap1 kernel: [  159.818617] RPC:       xs_tcp_send_request(44) = 0
2016-03-11T03:22:05.038073-06:00 imap1 kernel: [  159.848659] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:05.038080-06:00 imap1 kernel: [  159.848700] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:05.038081-06:00 imap1 kernel: [  159.848703] RPC:       reading TCP record fragment of length 24
2016-03-11T03:22:05.038082-06:00 imap1 kernel: [  159.848704] RPC:       reading XID (4 bytes)
2016-03-11T03:22:05.038082-06:00 imap1 kernel: [  159.848705] RPC:       reading request with XID dfc8121a
2016-03-11T03:22:05.038083-06:00 imap1 kernel: [  159.848706] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:05.038084-06:00 imap1 kernel: [  159.848707] RPC:       read reply XID dfc8121a
2016-03-11T03:22:05.038084-06:00 imap1 kernel: [  159.848708] RPC:       XID dfc8121a read 16 bytes
2016-03-11T03:22:05.038085-06:00 imap1 kernel: [  159.848710] RPC:       xprt = ffff88003cfe4000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
2016-03-11T03:22:05.038086-06:00 imap1 kernel: [  159.848718] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:05.042856-06:00 imap1 kernel: [  159.848782] RPC:    96 call_status (status 24)
2016-03-11T03:22:05.042865-06:00 imap1 kernel: [  159.848785] RPC:    96 call_decode (status 24)
2016-03-11T03:22:05.042866-06:00 imap1 kernel: [  159.848787] RPC:    96 call_decode result 0
2016-03-11T03:22:05.042867-06:00 imap1 kernel: [  159.848790] RPC:       rpc_release_client(ffff88003b53f800)
2016-03-11T03:22:05.042867-06:00 imap1 kernel: [  159.848803] RPC:       worker connecting xprt ffff880038d89000 via AF_LOCAL to /var/run/rpcbind.sock
2016-03-11T03:22:05.042868-06:00 imap1 kernel: [  159.848818] RPC:       xprt ffff880038d89000 connected to /var/run/rpcbind.sock
2016-03-11T03:22:05.042869-06:00 imap1 kernel: [  159.848820] RPC:       set up xprt to /var/run/rpcbind.sock via AF_LOCAL
2016-03-11T03:22:05.042870-06:00 imap1 kernel: [  159.848825] RPC:       creating rpcbind client for localhost (xprt ffff880038d89000)
2016-03-11T03:22:05.042871-06:00 imap1 kernel: [  159.848834] RPC:    98 call_start rpcbind2 proc NULL (sync)
2016-03-11T03:22:05.042872-06:00 imap1 kernel: [  159.848836] RPC:    98 call_reserve (status 0)
2016-03-11T03:22:05.042872-06:00 imap1 kernel: [  159.848837] RPC:    98 call_reserveresult (status 0)
2016-03-11T03:22:05.042873-06:00 imap1 kernel: [  159.848838] RPC:    98 call_refresh (status 0)
2016-03-11T03:22:05.042874-06:00 imap1 kernel: [  159.848839] RPC:    98 call_refreshresult (status 0)
2016-03-11T03:22:05.042875-06:00 imap1 kernel: [  159.848840] RPC:    98 call_allocate (status 0)
2016-03-11T03:22:05.042880-06:00 imap1 kernel: [  159.848842] RPC:    98 call_bind (status 0)
2016-03-11T03:22:05.042881-06:00 imap1 kernel: [  159.848843] RPC:    98 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.042882-06:00 imap1 kernel: [  159.848844] RPC:    98 call_transmit (status 0)
2016-03-11T03:22:05.042882-06:00 imap1 kernel: [  159.848845] RPC:    98 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.042883-06:00 imap1 kernel: [  159.848850] RPC:       xs_local_send_request(44) = 0
2016-03-11T03:22:05.042884-06:00 imap1 kernel: [  159.848930] RPC:       xs_data_ready...
2016-03-11T03:22:05.042885-06:00 imap1 kernel: [  159.848942] RPC:    98 call_status (status 24)
2016-03-11T03:22:05.042886-06:00 imap1 kernel: [  159.848943] RPC:    98 call_decode (status 24)
2016-03-11T03:22:05.042887-06:00 imap1 kernel: [  159.848945] RPC:    98 call_decode result 0
2016-03-11T03:22:05.042887-06:00 imap1 kernel: [  159.848947] RPC:       rpc_release_client(ffff88003af5a000)
2016-03-11T03:22:05.042888-06:00 imap1 kernel: [  159.848949] RPC:       creating rpcbind client for localhost (xprt ffff880038d89000)
2016-03-11T03:22:05.042889-06:00 imap1 kernel: [  159.848957] RPC:    99 call_start rpcbind4 proc NULL (sync)
2016-03-11T03:22:05.042890-06:00 imap1 kernel: [  159.848958] RPC:    99 call_reserve (status 0)
2016-03-11T03:22:05.042890-06:00 imap1 kernel: [  159.848960] RPC:    99 call_reserveresult (status 0)
2016-03-11T03:22:05.042891-06:00 imap1 kernel: [  159.848961] RPC:    99 call_refresh (status 0)
2016-03-11T03:22:05.042892-06:00 imap1 kernel: [  159.848962] RPC:    99 call_refreshresult (status 0)
2016-03-11T03:22:05.042893-06:00 imap1 kernel: [  159.848964] RPC:    99 call_allocate (status 0)
2016-03-11T03:22:05.042894-06:00 imap1 kernel: [  159.848965] RPC:    99 call_bind (status 0)
2016-03-11T03:22:05.042894-06:00 imap1 kernel: [  159.848966] RPC:    99 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.042895-06:00 imap1 kernel: [  159.848967] RPC:    99 call_transmit (status 0)
2016-03-11T03:22:05.042896-06:00 imap1 kernel: [  159.848968] RPC:    99 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.042897-06:00 imap1 kernel: [  159.848971] RPC:       xs_local_send_request(44) = 0
2016-03-11T03:22:05.042898-06:00 imap1 kernel: [  159.848982] RPC:       xs_data_ready...
2016-03-11T03:22:05.042898-06:00 imap1 kernel: [  159.848990] RPC:    99 call_status (status 24)
2016-03-11T03:22:05.042899-06:00 imap1 kernel: [  159.848991] RPC:    99 call_decode (status 24)
2016-03-11T03:22:05.042900-06:00 imap1 kernel: [  159.848992] RPC:    99 call_decode result 0
2016-03-11T03:22:05.042901-06:00 imap1 kernel: [  159.848994] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.042901-06:00 imap1 kernel: [  159.848996] RPC:   100 call_start rpcbind4 proc UNSET (sync)
2016-03-11T03:22:05.042902-06:00 imap1 kernel: [  159.848998] RPC:   100 call_reserve (status 0)
2016-03-11T03:22:05.042903-06:00 imap1 kernel: [  159.848999] RPC:   100 call_reserveresult (status 0)
2016-03-11T03:22:05.042903-06:00 imap1 kernel: [  159.849000] RPC:   100 call_refresh (status 0)
2016-03-11T03:22:05.042904-06:00 imap1 kernel: [  159.849001] RPC:   100 call_refreshresult (status 0)
2016-03-11T03:22:05.042905-06:00 imap1 kernel: [  159.849003] RPC:   100 call_allocate (status 0)
2016-03-11T03:22:05.042906-06:00 imap1 kernel: [  159.849004] RPC:   100 call_bind (status 0)
2016-03-11T03:22:05.042906-06:00 imap1 kernel: [  159.849005] RPC:   100 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.042907-06:00 imap1 kernel: [  159.849006] RPC:   100 call_transmit (status 0)
2016-03-11T03:22:05.042908-06:00 imap1 kernel: [  159.849008] RPC:   100 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.042908-06:00 imap1 kernel: [  159.849010] RPC:       xs_local_send_request(68) = 0
2016-03-11T03:22:05.042909-06:00 imap1 kernel: [  159.849024] RPC:       xs_data_ready...
2016-03-11T03:22:05.042911-06:00 imap1 kernel: [  159.849030] RPC:   100 call_status (status 28)
2016-03-11T03:22:05.042912-06:00 imap1 kernel: [  159.849031] RPC:   100 call_decode (status 28)
2016-03-11T03:22:05.042913-06:00 imap1 kernel: [  159.849033] RPC:   100 call_decode result 0
2016-03-11T03:22:05.042913-06:00 imap1 kernel: [  159.849035] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.042914-06:00 imap1 kernel: [  159.849037] RPC:   101 call_start rpcbind4 proc UNSET (sync)
2016-03-11T03:22:05.042916-06:00 imap1 kernel: [  159.849038] RPC:   101 call_reserve (status 0)
2016-03-11T03:22:05.042917-06:00 imap1 kernel: [  159.849039] RPC:   101 call_reserveresult (status 0)
2016-03-11T03:22:05.042917-06:00 imap1 kernel: [  159.849040] RPC:   101 call_refresh (status 0)
2016-03-11T03:22:05.042918-06:00 imap1 kernel: [  159.849041] RPC:   101 call_refreshresult (status 0)
2016-03-11T03:22:05.042919-06:00 imap1 kernel: [  159.849042] RPC:   101 call_allocate (status 0)
2016-03-11T03:22:05.042919-06:00 imap1 kernel: [  159.849044] RPC:   101 call_bind (status 0)
2016-03-11T03:22:05.042921-06:00 imap1 kernel: [  159.849045] RPC:   101 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.042922-06:00 imap1 kernel: [  159.849047] RPC:   101 call_transmit (status 0)
2016-03-11T03:22:05.042922-06:00 imap1 kernel: [  159.849048] RPC:   101 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.042923-06:00 imap1 kernel: [  159.849050] RPC:       xs_local_send_request(68) = 0
2016-03-11T03:22:05.042923-06:00 imap1 kernel: [  159.849061] RPC:       xs_data_ready...
2016-03-11T03:22:05.042924-06:00 imap1 kernel: [  159.849067] RPC:   101 call_status (status 28)
2016-03-11T03:22:05.042926-06:00 imap1 kernel: [  159.849068] RPC:   101 call_decode (status 28)
2016-03-11T03:22:05.042926-06:00 imap1 kernel: [  159.849069] RPC:   101 call_decode result 0
2016-03-11T03:22:05.042927-06:00 imap1 kernel: [  159.849072] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.042928-06:00 imap1 kernel: [  159.849073] RPC:   102 call_start rpcbind4 proc UNSET (sync)
2016-03-11T03:22:05.042928-06:00 imap1 kernel: [  159.849075] RPC:   102 call_reserve (status 0)
2016-03-11T03:22:05.042929-06:00 imap1 kernel: [  159.849076] RPC:   102 call_reserveresult (status 0)
2016-03-11T03:22:05.042931-06:00 imap1 kernel: [  159.849077] RPC:   102 call_refresh (status 0)
2016-03-11T03:22:05.042931-06:00 imap1 kernel: [  159.849078] RPC:   102 call_refreshresult (status 0)
2016-03-11T03:22:05.042932-06:00 imap1 kernel: [  159.849079] RPC:   102 call_allocate (status 0)
2016-03-11T03:22:05.042933-06:00 imap1 kernel: [  159.849080] RPC:   102 call_bind (status 0)
2016-03-11T03:22:05.042933-06:00 imap1 kernel: [  159.849081] RPC:   102 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.042935-06:00 imap1 kernel: [  159.849082] RPC:   102 call_transmit (status 0)
2016-03-11T03:22:05.042936-06:00 imap1 kernel: [  159.849083] RPC:   102 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.042937-06:00 imap1 kernel: [  159.849086] RPC:       xs_local_send_request(68) = 0
2016-03-11T03:22:05.042938-06:00 imap1 kernel: [  159.849096] RPC:       xs_data_ready...
2016-03-11T03:22:05.042939-06:00 imap1 kernel: [  159.849103] RPC:   102 call_status (status 28)
2016-03-11T03:22:05.042940-06:00 imap1 kernel: [  159.849104] RPC:   102 call_decode (status 28)
2016-03-11T03:22:05.042941-06:00 imap1 kernel: [  159.849105] RPC:   102 call_decode result 0
2016-03-11T03:22:05.042942-06:00 imap1 kernel: [  159.849107] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.042943-06:00 imap1 kernel: [  159.849118] RPC:   103 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.042943-06:00 imap1 kernel: [  159.849120] RPC:   103 call_reserve (status 0)
2016-03-11T03:22:05.042944-06:00 imap1 kernel: [  159.849122] RPC:   103 call_reserveresult (status 0)
2016-03-11T03:22:05.042945-06:00 imap1 kernel: [  159.849123] RPC:   103 call_refresh (status 0)
2016-03-11T03:22:05.042946-06:00 imap1 kernel: [  159.849124] RPC:   103 call_refreshresult (status 0)
2016-03-11T03:22:05.042947-06:00 imap1 kernel: [  159.849125] RPC:   103 call_allocate (status 0)
2016-03-11T03:22:05.042948-06:00 imap1 kernel: [  159.849126] RPC:   103 call_bind (status 0)
2016-03-11T03:22:05.042948-06:00 imap1 kernel: [  159.849127] RPC:   103 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.042949-06:00 imap1 kernel: [  159.849128] RPC:   103 call_transmit (status 0)
2016-03-11T03:22:05.042950-06:00 imap1 kernel: [  159.849130] RPC:   103 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.042951-06:00 imap1 kernel: [  159.849132] RPC:       xs_local_send_request(88) = 0
2016-03-11T03:22:05.042952-06:00 imap1 kernel: [  159.849147] RPC:       xs_data_ready...
2016-03-11T03:22:05.042952-06:00 imap1 kernel: [  159.849153] RPC:   103 call_status (status 28)
2016-03-11T03:22:05.042953-06:00 imap1 kernel: [  159.849155] RPC:   103 call_decode (status 28)
2016-03-11T03:22:05.042953-06:00 imap1 kernel: [  159.849157] RPC:   103 call_decode result 0
2016-03-11T03:22:05.042954-06:00 imap1 kernel: [  159.849158] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.042956-06:00 imap1 kernel: [  159.849161] RPC:   104 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.042956-06:00 imap1 kernel: [  159.849162] RPC:   104 call_reserve (status 0)
2016-03-11T03:22:05.042957-06:00 imap1 kernel: [  159.849163] RPC:   104 call_reserveresult (status 0)
2016-03-11T03:22:05.042958-06:00 imap1 kernel: [  159.849164] RPC:   104 call_refresh (status 0)
2016-03-11T03:22:05.042958-06:00 imap1 kernel: [  159.849166] RPC:   104 call_refreshresult (status 0)
2016-03-11T03:22:05.042959-06:00 imap1 kernel: [  159.849167] RPC:   104 call_allocate (status 0)
2016-03-11T03:22:05.042960-06:00 imap1 kernel: [  159.849169] RPC:   104 call_bind (status 0)
2016-03-11T03:22:05.042961-06:00 imap1 kernel: [  159.849170] RPC:   104 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.042961-06:00 imap1 kernel: [  159.849171] RPC:   104 call_transmit (status 0)
2016-03-11T03:22:05.042962-06:00 imap1 kernel: [  159.849172] RPC:   104 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.042963-06:00 imap1 kernel: [  159.849175] RPC:       xs_local_send_request(88) = 0
2016-03-11T03:22:05.042964-06:00 imap1 kernel: [  159.849187] RPC:       xs_data_ready...
2016-03-11T03:22:05.042964-06:00 imap1 kernel: [  159.849194] RPC:   104 call_status (status 28)
2016-03-11T03:22:05.042965-06:00 imap1 kernel: [  159.849195] RPC:   104 call_decode (status 28)
2016-03-11T03:22:05.042966-06:00 imap1 kernel: [  159.849196] RPC:   104 call_decode result 0
2016-03-11T03:22:05.042967-06:00 imap1 kernel: [  159.849197] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.042968-06:00 imap1 kernel: [  159.849200] RPC:   105 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.042969-06:00 imap1 kernel: [  159.849201] RPC:   105 call_reserve (status 0)
2016-03-11T03:22:05.042970-06:00 imap1 kernel: [  159.849203] RPC:   105 call_reserveresult (status 0)
2016-03-11T03:22:05.042971-06:00 imap1 kernel: [  159.849204] RPC:   105 call_refresh (status 0)
2016-03-11T03:22:05.042971-06:00 imap1 kernel: [  159.849205] RPC:   105 call_refreshresult (status 0)
2016-03-11T03:22:05.042972-06:00 imap1 kernel: [  159.849206] RPC:   105 call_allocate (status 0)
2016-03-11T03:22:05.042973-06:00 imap1 kernel: [  159.849208] RPC:   105 call_bind (status 0)
2016-03-11T03:22:05.042974-06:00 imap1 kernel: [  159.849209] RPC:   105 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.042975-06:00 imap1 kernel: [  159.849210] RPC:   105 call_transmit (status 0)
2016-03-11T03:22:05.042975-06:00 imap1 kernel: [  159.849211] RPC:   105 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.042976-06:00 imap1 kernel: [  159.849213] RPC:       xs_local_send_request(88) = 0
2016-03-11T03:22:05.042976-06:00 imap1 kernel: [  159.849225] RPC:       xs_data_ready...
2016-03-11T03:22:05.042978-06:00 imap1 kernel: [  159.849231] RPC:   105 call_status (status 28)
2016-03-11T03:22:05.042979-06:00 imap1 kernel: [  159.849233] RPC:   105 call_decode (status 28)
2016-03-11T03:22:05.042979-06:00 imap1 kernel: [  159.849234] RPC:   105 call_decode result 0
2016-03-11T03:22:05.042980-06:00 imap1 kernel: [  159.849236] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.042981-06:00 imap1 kernel: [  159.849247] RPC:   106 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.042981-06:00 imap1 kernel: [  159.849248] RPC:   106 call_reserve (status 0)
2016-03-11T03:22:05.043059-06:00 imap1 kernel: [  159.849250] RPC:   106 call_reserveresult (status 0)
2016-03-11T03:22:05.043060-06:00 imap1 kernel: [  159.849251] RPC:   106 call_refresh (status 0)
2016-03-11T03:22:05.043061-06:00 imap1 kernel: [  159.849252] RPC:   106 call_refreshresult (status 0)
2016-03-11T03:22:05.043062-06:00 imap1 kernel: [  159.849253] RPC:   106 call_allocate (status 0)
2016-03-11T03:22:05.043062-06:00 imap1 kernel: [  159.849255] RPC:   106 call_bind (status 0)
2016-03-11T03:22:05.043063-06:00 imap1 kernel: [  159.849256] RPC:   106 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043064-06:00 imap1 kernel: [  159.849257] RPC:   106 call_transmit (status 0)
2016-03-11T03:22:05.043065-06:00 imap1 kernel: [  159.849258] RPC:   106 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043066-06:00 imap1 kernel: [  159.849261] RPC:       xs_local_send_request(88) = 0
2016-03-11T03:22:05.043067-06:00 imap1 kernel: [  159.849275] RPC:       xs_data_ready...
2016-03-11T03:22:05.043068-06:00 imap1 kernel: [  159.849282] RPC:   106 call_status (status 28)
2016-03-11T03:22:05.043069-06:00 imap1 kernel: [  159.849283] RPC:   106 call_decode (status 28)
2016-03-11T03:22:05.043070-06:00 imap1 kernel: [  159.849285] RPC:   106 call_decode result 0
2016-03-11T03:22:05.043071-06:00 imap1 kernel: [  159.849287] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043071-06:00 imap1 kernel: [  159.849289] RPC:   107 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.043072-06:00 imap1 kernel: [  159.849290] RPC:   107 call_reserve (status 0)
2016-03-11T03:22:05.043073-06:00 imap1 kernel: [  159.849291] RPC:   107 call_reserveresult (status 0)
2016-03-11T03:22:05.043073-06:00 imap1 kernel: [  159.849293] RPC:   107 call_refresh (status 0)
2016-03-11T03:22:05.043074-06:00 imap1 kernel: [  159.849294] RPC:   107 call_refreshresult (status 0)
2016-03-11T03:22:05.043075-06:00 imap1 kernel: [  159.849296] RPC:   107 call_allocate (status 0)
2016-03-11T03:22:05.043076-06:00 imap1 kernel: [  159.849297] RPC:   107 call_bind (status 0)
2016-03-11T03:22:05.043076-06:00 imap1 kernel: [  159.849298] RPC:   107 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043077-06:00 imap1 kernel: [  159.849299] RPC:   107 call_transmit (status 0)
2016-03-11T03:22:05.043078-06:00 imap1 kernel: [  159.849300] RPC:   107 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043079-06:00 imap1 kernel: [  159.849303] RPC:       xs_local_send_request(88) = 0
2016-03-11T03:22:05.043080-06:00 imap1 kernel: [  159.849315] RPC:       xs_data_ready...
2016-03-11T03:22:05.043080-06:00 imap1 kernel: [  159.849321] RPC:   107 call_status (status 28)
2016-03-11T03:22:05.043081-06:00 imap1 kernel: [  159.849323] RPC:   107 call_decode (status 28)
2016-03-11T03:22:05.043082-06:00 imap1 kernel: [  159.849324] RPC:   107 call_decode result 0
2016-03-11T03:22:05.043082-06:00 imap1 kernel: [  159.849325] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043084-06:00 imap1 kernel: [  159.849328] RPC:   108 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.043084-06:00 imap1 kernel: [  159.849329] RPC:   108 call_reserve (status 0)
2016-03-11T03:22:05.043085-06:00 imap1 kernel: [  159.849330] RPC:   108 call_reserveresult (status 0)
2016-03-11T03:22:05.043086-06:00 imap1 kernel: [  159.849332] RPC:   108 call_refresh (status 0)
2016-03-11T03:22:05.043086-06:00 imap1 kernel: [  159.849333] RPC:   108 call_refreshresult (status 0)
2016-03-11T03:22:05.043087-06:00 imap1 kernel: [  159.849334] RPC:   108 call_allocate (status 0)
2016-03-11T03:22:05.043088-06:00 imap1 kernel: [  159.849335] RPC:   108 call_bind (status 0)
2016-03-11T03:22:05.043089-06:00 imap1 kernel: [  159.849337] RPC:   108 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043090-06:00 imap1 kernel: [  159.849338] RPC:   108 call_transmit (status 0)
2016-03-11T03:22:05.043090-06:00 imap1 kernel: [  159.849339] RPC:   108 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043091-06:00 imap1 kernel: [  159.849341] RPC:       xs_local_send_request(88) = 0
2016-03-11T03:22:05.043092-06:00 imap1 kernel: [  159.849354] RPC:       xs_data_ready...
2016-03-11T03:22:05.043093-06:00 imap1 kernel: [  159.849360] RPC:   108 call_status (status 28)
2016-03-11T03:22:05.043094-06:00 imap1 kernel: [  159.849361] RPC:   108 call_decode (status 28)
2016-03-11T03:22:05.043095-06:00 imap1 kernel: [  159.849363] RPC:   108 call_decode result 0
2016-03-11T03:22:05.043096-06:00 imap1 kernel: [  159.849364] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043097-06:00 imap1 kernel: [  159.849374] RPC:   109 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.043098-06:00 imap1 kernel: [  159.849376] RPC:   109 call_reserve (status 0)
2016-03-11T03:22:05.043098-06:00 imap1 kernel: [  159.849377] RPC:   109 call_reserveresult (status 0)
2016-03-11T03:22:05.043099-06:00 imap1 kernel: [  159.849379] RPC:   109 call_refresh (status 0)
2016-03-11T03:22:05.043100-06:00 imap1 kernel: [  159.849380] RPC:   109 call_refreshresult (status 0)
2016-03-11T03:22:05.043100-06:00 imap1 kernel: [  159.849381] RPC:   109 call_allocate (status 0)
2016-03-11T03:22:05.043104-06:00 imap1 kernel: [  159.849382] RPC:   109 call_bind (status 0)
2016-03-11T03:22:05.043105-06:00 imap1 kernel: [  159.849383] RPC:   109 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043106-06:00 imap1 kernel: [  159.849384] RPC:   109 call_transmit (status 0)
2016-03-11T03:22:05.043106-06:00 imap1 kernel: [  159.849386] RPC:   109 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043107-06:00 imap1 kernel: [  159.849388] RPC:       xs_local_send_request(84) = 0
2016-03-11T03:22:05.043107-06:00 imap1 kernel: [  159.849401] RPC:       xs_data_ready...
2016-03-11T03:22:05.043109-06:00 imap1 kernel: [  159.849408] RPC:   109 call_status (status 28)
2016-03-11T03:22:05.043110-06:00 imap1 kernel: [  159.849409] RPC:   109 call_decode (status 28)
2016-03-11T03:22:05.043111-06:00 imap1 kernel: [  159.849410] RPC:   109 call_decode result 0
2016-03-11T03:22:05.043111-06:00 imap1 kernel: [  159.849412] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043112-06:00 imap1 kernel: [  159.849415] RPC:   110 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.043113-06:00 imap1 kernel: [  159.849416] RPC:   110 call_reserve (status 0)
2016-03-11T03:22:05.043116-06:00 imap1 kernel: [  159.849417] RPC:   110 call_reserveresult (status 0)
2016-03-11T03:22:05.043116-06:00 imap1 kernel: [  159.849418] RPC:   110 call_refresh (status 0)
2016-03-11T03:22:05.043117-06:00 imap1 kernel: [  159.849419] RPC:   110 call_refreshresult (status 0)
2016-03-11T03:22:05.043118-06:00 imap1 kernel: [  159.849420] RPC:   110 call_allocate (status 0)
2016-03-11T03:22:05.043118-06:00 imap1 kernel: [  159.849421] RPC:   110 call_bind (status 0)
2016-03-11T03:22:05.043119-06:00 imap1 kernel: [  159.849423] RPC:   110 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043121-06:00 imap1 kernel: [  159.849424] RPC:   110 call_transmit (status 0)
2016-03-11T03:22:05.043121-06:00 imap1 kernel: [  159.849425] RPC:   110 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043122-06:00 imap1 kernel: [  159.849429] RPC:       xs_local_send_request(84) = 0
2016-03-11T03:22:05.043123-06:00 imap1 kernel: [  159.849440] RPC:       xs_data_ready...
2016-03-11T03:22:05.043123-06:00 imap1 kernel: [  159.849446] RPC:   110 call_status (status 28)
2016-03-11T03:22:05.043125-06:00 imap1 kernel: [  159.849447] RPC:   110 call_decode (status 28)
2016-03-11T03:22:05.043126-06:00 imap1 kernel: [  159.849449] RPC:   110 call_decode result 0
2016-03-11T03:22:05.043126-06:00 imap1 kernel: [  159.849451] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043127-06:00 imap1 kernel: [  159.849453] RPC:   111 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.043128-06:00 imap1 kernel: [  159.849455] RPC:   111 call_reserve (status 0)
2016-03-11T03:22:05.043128-06:00 imap1 kernel: [  159.849456] RPC:   111 call_reserveresult (status 0)
2016-03-11T03:22:05.043130-06:00 imap1 kernel: [  159.849457] RPC:   111 call_refresh (status 0)
2016-03-11T03:22:05.043131-06:00 imap1 kernel: [  159.849458] RPC:   111 call_refreshresult (status 0)
2016-03-11T03:22:05.043132-06:00 imap1 kernel: [  159.849459] RPC:   111 call_allocate (status 0)
2016-03-11T03:22:05.043132-06:00 imap1 kernel: [  159.849460] RPC:   111 call_bind (status 0)
2016-03-11T03:22:05.043133-06:00 imap1 kernel: [  159.849462] RPC:   111 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043133-06:00 imap1 kernel: [  159.849463] RPC:   111 call_transmit (status 0)
2016-03-11T03:22:05.043135-06:00 imap1 kernel: [  159.849464] RPC:   111 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043136-06:00 imap1 kernel: [  159.849467] RPC:       xs_local_send_request(84) = 0
2016-03-11T03:22:05.043137-06:00 imap1 kernel: [  159.849478] RPC:       xs_data_ready...
2016-03-11T03:22:05.043137-06:00 imap1 kernel: [  159.849484] RPC:   111 call_status (status 28)
2016-03-11T03:22:05.043138-06:00 imap1 kernel: [  159.849486] RPC:   111 call_decode (status 28)
2016-03-11T03:22:05.043139-06:00 imap1 kernel: [  159.849487] RPC:   111 call_decode result 0
2016-03-11T03:22:05.043140-06:00 imap1 kernel: [  159.849488] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043141-06:00 imap1 kernel: [  159.849498] RPC:   112 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.043142-06:00 imap1 kernel: [  159.849499] RPC:   112 call_reserve (status 0)
2016-03-11T03:22:05.043142-06:00 imap1 kernel: [  159.849501] RPC:   112 call_reserveresult (status 0)
2016-03-11T03:22:05.043143-06:00 imap1 kernel: [  159.849502] RPC:   112 call_refresh (status 0)
2016-03-11T03:22:05.043144-06:00 imap1 kernel: [  159.849503] RPC:   112 call_refreshresult (status 0)
2016-03-11T03:22:05.043146-06:00 imap1 kernel: [  159.849504] RPC:   112 call_allocate (status 0)
2016-03-11T03:22:05.043146-06:00 imap1 kernel: [  159.849506] RPC:   112 call_bind (status 0)
2016-03-11T03:22:05.043147-06:00 imap1 kernel: [  159.849507] RPC:   112 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043148-06:00 imap1 kernel: [  159.849508] RPC:   112 call_transmit (status 0)
2016-03-11T03:22:05.043148-06:00 imap1 kernel: [  159.849509] RPC:   112 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043149-06:00 imap1 kernel: [  159.849512] RPC:       xs_local_send_request(84) = 0
2016-03-11T03:22:05.043151-06:00 imap1 kernel: [  159.849525] RPC:       xs_data_ready...
2016-03-11T03:22:05.043152-06:00 imap1 kernel: [  159.849532] RPC:   112 call_status (status 28)
2016-03-11T03:22:05.043152-06:00 imap1 kernel: [  159.849533] RPC:   112 call_decode (status 28)
2016-03-11T03:22:05.043153-06:00 imap1 kernel: [  159.849534] RPC:   112 call_decode result 0
2016-03-11T03:22:05.043153-06:00 imap1 kernel: [  159.849536] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043155-06:00 imap1 kernel: [  159.849538] RPC:   113 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.043156-06:00 imap1 kernel: [  159.849539] RPC:   113 call_reserve (status 0)
2016-03-11T03:22:05.043157-06:00 imap1 kernel: [  159.849541] RPC:   113 call_reserveresult (status 0)
2016-03-11T03:22:05.043157-06:00 imap1 kernel: [  159.849542] RPC:   113 call_refresh (status 0)
2016-03-11T03:22:05.043158-06:00 imap1 kernel: [  159.849543] RPC:   113 call_refreshresult (status 0)
2016-03-11T03:22:05.043159-06:00 imap1 kernel: [  159.849545] RPC:   113 call_allocate (status 0)
2016-03-11T03:22:05.043161-06:00 imap1 kernel: [  159.849546] RPC:   113 call_bind (status 0)
2016-03-11T03:22:05.043161-06:00 imap1 kernel: [  159.849547] RPC:   113 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043162-06:00 imap1 kernel: [  159.849548] RPC:   113 call_transmit (status 0)
2016-03-11T03:22:05.043163-06:00 imap1 kernel: [  159.849549] RPC:   113 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043163-06:00 imap1 kernel: [  159.849552] RPC:       xs_local_send_request(84) = 0
2016-03-11T03:22:05.043164-06:00 imap1 kernel: [  159.849564] RPC:       xs_data_ready...
2016-03-11T03:22:05.043167-06:00 imap1 kernel: [  159.849570] RPC:   113 call_status (status 28)
2016-03-11T03:22:05.043167-06:00 imap1 kernel: [  159.849571] RPC:   113 call_decode (status 28)
2016-03-11T03:22:05.043168-06:00 imap1 kernel: [  159.849572] RPC:   113 call_decode result 0
2016-03-11T03:22:05.043169-06:00 imap1 kernel: [  159.849574] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043169-06:00 imap1 kernel: [  159.849577] RPC:   114 call_start rpcbind4 proc SET (sync)
2016-03-11T03:22:05.043170-06:00 imap1 kernel: [  159.849578] RPC:   114 call_reserve (status 0)
2016-03-11T03:22:05.043172-06:00 imap1 kernel: [  159.849579] RPC:   114 call_reserveresult (status 0)
2016-03-11T03:22:05.043173-06:00 imap1 kernel: [  159.849580] RPC:   114 call_refresh (status 0)
2016-03-11T03:22:05.043173-06:00 imap1 kernel: [  159.849581] RPC:   114 call_refreshresult (status 0)
2016-03-11T03:22:05.043174-06:00 imap1 kernel: [  159.849582] RPC:   114 call_allocate (status 0)
2016-03-11T03:22:05.043174-06:00 imap1 kernel: [  159.849583] RPC:   114 call_bind (status 0)
2016-03-11T03:22:05.043175-06:00 imap1 kernel: [  159.849584] RPC:   114 call_connect xprt ffff880038d89000 is connected
2016-03-11T03:22:05.043177-06:00 imap1 kernel: [  159.849586] RPC:   114 call_transmit (status 0)
2016-03-11T03:22:05.043178-06:00 imap1 kernel: [  159.849587] RPC:   114 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043178-06:00 imap1 kernel: [  159.849590] RPC:       xs_local_send_request(84) = 0
2016-03-11T03:22:05.043179-06:00 imap1 kernel: [  159.849601] RPC:       xs_data_ready...
2016-03-11T03:22:05.043180-06:00 imap1 kernel: [  159.849607] RPC:   114 call_status (status 28)
2016-03-11T03:22:05.043182-06:00 imap1 kernel: [  159.849608] RPC:   114 call_decode (status 28)
2016-03-11T03:22:05.043182-06:00 imap1 kernel: [  159.849610] RPC:   114 call_decode result 0
2016-03-11T03:22:05.043183-06:00 imap1 kernel: [  159.849611] RPC:       rpc_release_client(ffff88003af5bc00)
2016-03-11T03:22:05.043226-06:00 imap1 kernel: [  159.849651] RPC:       set up xprt to 10.20.0.30 (autobind) via tcp
2016-03-11T03:22:05.043226-06:00 imap1 kernel: [  159.849656] RPC:       creating lockd client for 10.20.0.30 (xprt ffff880038d88800)
2016-03-11T03:22:05.043227-06:00 imap1 kernel: [  159.849663] RPC:       creating nfs client for 10.20.0.30 (xprt ffff88003cfe4000)
2016-03-11T03:22:05.043229-06:00 imap1 kernel: [  159.849676] RPC:   115 call_start nfs3 proc FSINFO (sync)
2016-03-11T03:22:05.043230-06:00 imap1 kernel: [  159.849677] RPC:   115 call_reserve (status 0)
2016-03-11T03:22:05.043230-06:00 imap1 kernel: [  159.849679] RPC:   115 call_reserveresult (status 0)
2016-03-11T03:22:05.043231-06:00 imap1 kernel: [  159.849680] RPC:   115 call_refresh (status 0)
2016-03-11T03:22:05.043232-06:00 imap1 kernel: [  159.849682] RPC:   115 call_refreshresult (status 0)
2016-03-11T03:22:05.043232-06:00 imap1 kernel: [  159.849683] RPC:   115 call_allocate (status 0)
2016-03-11T03:22:05.043234-06:00 imap1 kernel: [  159.849684] RPC:   115 call_bind (status 0)
2016-03-11T03:22:05.043235-06:00 imap1 kernel: [  159.849686] RPC:   115 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:22:05.043236-06:00 imap1 kernel: [  159.849687] RPC:   115 call_transmit (status 0)
2016-03-11T03:22:05.043236-06:00 imap1 kernel: [  159.849688] RPC:   115 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043237-06:00 imap1 kernel: [  159.849709] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:22:05.043237-06:00 imap1 kernel: [  159.849867] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:05.043239-06:00 imap1 kernel: [  159.849874] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:05.043240-06:00 imap1 kernel: [  159.849875] RPC:       reading TCP record fragment of length 164
2016-03-11T03:22:05.043241-06:00 imap1 kernel: [  159.849876] RPC:       reading XID (4 bytes)
2016-03-11T03:22:05.043241-06:00 imap1 kernel: [  159.849877] RPC:       reading reply for XID e0c8121a
2016-03-11T03:22:05.043242-06:00 imap1 kernel: [  159.849878] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:05.043243-06:00 imap1 kernel: [  159.849879] RPC:       read reply XID e0c8121a
2016-03-11T03:22:05.043244-06:00 imap1 kernel: [  159.849881] RPC:       XID e0c8121a read 156 bytes
2016-03-11T03:22:05.043245-06:00 imap1 kernel: [  159.849882] RPC:       xprt = ffff88003cfe4000, tcp_copied = 164, tcp_offset = 164, tcp_reclen = 164
2016-03-11T03:22:05.043246-06:00 imap1 kernel: [  159.849891] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:05.043246-06:00 imap1 kernel: [  159.849950] RPC:   115 call_status (status 164)
2016-03-11T03:22:05.043247-06:00 imap1 kernel: [  159.849953] RPC:   115 call_decode (status 164)
2016-03-11T03:22:05.043249-06:00 imap1 kernel: [  159.849956] RPC:   115 call_decode result 0
2016-03-11T03:22:05.043250-06:00 imap1 kernel: [  159.849959] RPC:       rpc_release_client(ffff8800350d7000)
2016-03-11T03:22:05.043250-06:00 imap1 kernel: [  159.849964] RPC:   116 call_start nfs3 proc PATHCONF (sync)
2016-03-11T03:22:05.043251-06:00 imap1 kernel: [  159.849965] RPC:   116 call_reserve (status 0)
2016-03-11T03:22:05.043252-06:00 imap1 kernel: [  159.849967] RPC:   116 call_reserveresult (status 0)
2016-03-11T03:22:05.043252-06:00 imap1 kernel: [  159.849968] RPC:   116 call_refresh (status 0)
2016-03-11T03:22:05.043254-06:00 imap1 kernel: [  159.849970] RPC:   116 call_refreshresult (status 0)
2016-03-11T03:22:05.043255-06:00 imap1 kernel: [  159.849971] RPC:   116 call_allocate (status 0)
2016-03-11T03:22:05.043256-06:00 imap1 kernel: [  159.849972] RPC:   116 call_bind (status 0)
2016-03-11T03:22:05.043256-06:00 imap1 kernel: [  159.849973] RPC:   116 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:22:05.043257-06:00 imap1 kernel: [  159.849974] RPC:   116 call_transmit (status 0)
2016-03-11T03:22:05.043257-06:00 imap1 kernel: [  159.849976] RPC:   116 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043259-06:00 imap1 kernel: [  159.849999] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:22:05.043260-06:00 imap1 kernel: [  159.850184] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:05.043261-06:00 imap1 kernel: [  159.850190] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:05.043261-06:00 imap1 kernel: [  159.850191] RPC:       reading TCP record fragment of length 140
2016-03-11T03:22:05.043262-06:00 imap1 kernel: [  159.850192] RPC:       reading XID (4 bytes)
2016-03-11T03:22:05.043262-06:00 imap1 kernel: [  159.850193] RPC:       reading reply for XID e1c8121a
2016-03-11T03:22:05.043264-06:00 imap1 kernel: [  159.850194] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:05.043265-06:00 imap1 kernel: [  159.850195] RPC:       read reply XID e1c8121a
2016-03-11T03:22:05.043266-06:00 imap1 kernel: [  159.850196] RPC:       XID e1c8121a read 132 bytes
2016-03-11T03:22:05.043266-06:00 imap1 kernel: [  159.850198] RPC:       xprt = ffff88003cfe4000, tcp_copied = 140, tcp_offset = 140, tcp_reclen = 140
2016-03-11T03:22:05.043267-06:00 imap1 kernel: [  159.850207] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:05.043269-06:00 imap1 kernel: [  159.850248] RPC:   116 call_status (status 140)
2016-03-11T03:22:05.043269-06:00 imap1 kernel: [  159.850249] RPC:   116 call_decode (status 140)
2016-03-11T03:22:05.043270-06:00 imap1 kernel: [  159.850251] RPC:   116 call_decode result 0
2016-03-11T03:22:05.043271-06:00 imap1 kernel: [  159.850255] RPC:       rpc_release_client(ffff8800350d7000)
2016-03-11T03:22:05.043271-06:00 imap1 kernel: [  159.850313] RPC:   117 call_start nfs3 proc FSINFO (sync)
2016-03-11T03:22:05.043272-06:00 imap1 kernel: [  159.850314] RPC:   117 call_reserve (status 0)
2016-03-11T03:22:05.043273-06:00 imap1 kernel: [  159.850316] RPC:   117 call_reserveresult (status 0)
2016-03-11T03:22:05.043274-06:00 imap1 kernel: [  159.850317] RPC:   117 call_refresh (status 0)
2016-03-11T03:22:05.043275-06:00 imap1 kernel: [  159.850319] RPC:   117 call_refreshresult (status 0)
2016-03-11T03:22:05.043275-06:00 imap1 kernel: [  159.850320] RPC:   117 call_allocate (status 0)
2016-03-11T03:22:05.043276-06:00 imap1 kernel: [  159.850322] RPC:   117 call_bind (status 0)
2016-03-11T03:22:05.043277-06:00 imap1 kernel: [  159.850323] RPC:   117 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:22:05.043279-06:00 imap1 kernel: [  159.850324] RPC:   117 call_transmit (status 0)
2016-03-11T03:22:05.043280-06:00 imap1 kernel: [  159.850325] RPC:   117 rpc_xdr_encode (status 0)
2016-03-11T03:22:05.043281-06:00 imap1 kernel: [  159.850343] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:22:05.043281-06:00 imap1 kernel: [  159.850534] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:05.043282-06:00 imap1 kernel: [  159.850540] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:05.043282-06:00 imap1 kernel: [  159.850541] RPC:       reading TCP record fragment of length 164
2016-03-11T03:22:05.043284-06:00 imap1 kernel: [  159.850542] RPC:       reading XID (4 bytes)
2016-03-11T03:22:05.043285-06:00 imap1 kernel: [  159.850543] RPC:       reading reply for XID e2c8121a
2016-03-11T03:22:05.043286-06:00 imap1 kernel: [  159.850544] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:05.043286-06:00 imap1 kernel: [  159.850545] RPC:       read reply XID e2c8121a
2016-03-11T03:22:05.043287-06:00 imap1 kernel: [  159.850546] RPC:       XID e2c8121a read 156 bytes
2016-03-11T03:22:05.043288-06:00 imap1 kernel: [  159.850548] RPC:       xprt = ffff88003cfe4000, tcp_copied = 164, tcp_offset = 164, tcp_reclen = 164
2016-03-11T03:22:05.043290-06:00 imap1 kernel: [  159.850554] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:05.043290-06:00 imap1 kernel: [  159.852333] RPC:   117 call_status (status 164)
2016-03-11T03:22:05.043291-06:00 imap1 kernel: [  159.852336] RPC:   117 call_decode (status 164)
2016-03-11T03:22:05.043292-06:00 imap1 kernel: [  159.852339] RPC:   117 call_decode result 0
2016-03-11T03:22:05.043292-06:00 imap1 kernel: [  159.852342] RPC:       rpc_release_client(ffff8800350d7000)

# Forgot the sudo
ls /mnt/mail

2016-03-11T03:22:06.517842-06:00 imap1 kernel: [  161.327415] RPC:   118 call_start nfs3 proc ACCESS (sync)
2016-03-11T03:22:06.517857-06:00 imap1 kernel: [  161.327419] RPC:   118 call_reserve (status 0)
2016-03-11T03:22:06.517859-06:00 imap1 kernel: [  161.327423] RPC:   118 call_reserveresult (status 0)
2016-03-11T03:22:06.517860-06:00 imap1 kernel: [  161.327425] RPC:   118 call_refresh (status 0)
2016-03-11T03:22:06.517861-06:00 imap1 kernel: [  161.327427] RPC:   118 call_refreshresult (status 0)
2016-03-11T03:22:06.517862-06:00 imap1 kernel: [  161.327429] RPC:   118 call_allocate (status 0)
2016-03-11T03:22:06.517863-06:00 imap1 kernel: [  161.327430] RPC:   118 call_bind (status 0)
2016-03-11T03:22:06.517864-06:00 imap1 kernel: [  161.327433] RPC:   118 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:22:06.517865-06:00 imap1 kernel: [  161.327434] RPC:   118 call_transmit (status 0)
2016-03-11T03:22:06.517865-06:00 imap1 kernel: [  161.327435] RPC:   118 rpc_xdr_encode (status 0)
2016-03-11T03:22:06.517866-06:00 imap1 kernel: [  161.327467] RPC:       xs_tcp_send_request(136) = 0
2016-03-11T03:22:06.517867-06:00 imap1 kernel: [  161.327760] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:06.517868-06:00 imap1 kernel: [  161.327793] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:06.517869-06:00 imap1 kernel: [  161.327795] RPC:       reading TCP record fragment of length 120
2016-03-11T03:22:06.517870-06:00 imap1 kernel: [  161.327796] RPC:       reading XID (4 bytes)
2016-03-11T03:22:06.517870-06:00 imap1 kernel: [  161.327798] RPC:       reading reply for XID e3c8121a
2016-03-11T03:22:06.517871-06:00 imap1 kernel: [  161.327799] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:06.517872-06:00 imap1 kernel: [  161.327800] RPC:       read reply XID e3c8121a
2016-03-11T03:22:06.517874-06:00 imap1 kernel: [  161.327802] RPC:       XID e3c8121a read 112 bytes
2016-03-11T03:22:06.517875-06:00 imap1 kernel: [  161.327803] RPC:       xprt = ffff88003cfe4000, tcp_copied = 120, tcp_offset = 120, tcp_reclen = 120
2016-03-11T03:22:06.517875-06:00 imap1 kernel: [  161.327809] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:06.517876-06:00 imap1 kernel: [  161.327815] RPC:   118 call_status (status 120)
2016-03-11T03:22:06.517877-06:00 imap1 kernel: [  161.327817] RPC:   118 call_decode (status 120)
2016-03-11T03:22:06.517878-06:00 imap1 kernel: [  161.327821] RPC:   118 call_decode result 0
2016-03-11T03:22:06.517879-06:00 imap1 kernel: [  161.327825] RPC:       rpc_release_client(ffff8800350d7000)

sudo ls /mnt/mail

2016-03-11T03:22:10.777499-06:00 imap1 kernel: [  165.584707] RPC:   119 call_start nfs3 proc ACCESS (sync)
2016-03-11T03:22:10.777512-06:00 imap1 kernel: [  165.584710] RPC:   119 call_reserve (status 0)
2016-03-11T03:22:10.777514-06:00 imap1 kernel: [  165.584714] RPC:   119 call_reserveresult (status 0)
2016-03-11T03:22:10.777516-06:00 imap1 kernel: [  165.584716] RPC:   119 call_refresh (status 0)
2016-03-11T03:22:10.777517-06:00 imap1 kernel: [  165.584719] RPC:   119 call_refreshresult (status 0)
2016-03-11T03:22:10.777518-06:00 imap1 kernel: [  165.584720] RPC:   119 call_allocate (status 0)
2016-03-11T03:22:10.777519-06:00 imap1 kernel: [  165.584721] RPC:   119 call_bind (status 0)
2016-03-11T03:22:10.777521-06:00 imap1 kernel: [  165.584723] RPC:   119 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:22:10.777522-06:00 imap1 kernel: [  165.584725] RPC:   119 call_transmit (status 0)
2016-03-11T03:22:10.777523-06:00 imap1 kernel: [  165.584726] RPC:   119 rpc_xdr_encode (status 0)
2016-03-11T03:22:10.777524-06:00 imap1 kernel: [  165.584757] RPC:       xs_tcp_send_request(116) = 0
2016-03-11T03:22:10.777526-06:00 imap1 kernel: [  165.584997] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:10.777527-06:00 imap1 kernel: [  165.585040] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:10.777528-06:00 imap1 kernel: [  165.585043] RPC:       reading TCP record fragment of length 120
2016-03-11T03:22:10.777529-06:00 imap1 kernel: [  165.585045] RPC:       reading XID (4 bytes)
2016-03-11T03:22:10.777530-06:00 imap1 kernel: [  165.585047] RPC:       reading reply for XID e4c8121a
2016-03-11T03:22:10.777531-06:00 imap1 kernel: [  165.585049] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:10.777533-06:00 imap1 kernel: [  165.585051] RPC:       read reply XID e4c8121a
2016-03-11T03:22:10.777534-06:00 imap1 kernel: [  165.585054] RPC:       XID e4c8121a read 112 bytes
2016-03-11T03:22:10.777536-06:00 imap1 kernel: [  165.585057] RPC:       xprt = ffff88003cfe4000, tcp_copied = 120, tcp_offset = 120, tcp_reclen = 120
2016-03-11T03:22:10.777537-06:00 imap1 kernel: [  165.585063] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:10.777538-06:00 imap1 kernel: [  165.585071] RPC:   119 call_status (status 120)
2016-03-11T03:22:10.777539-06:00 imap1 kernel: [  165.585073] RPC:   119 call_decode (status 120)
2016-03-11T03:22:10.777540-06:00 imap1 kernel: [  165.585077] RPC:   119 call_decode result 0
2016-03-11T03:22:10.777542-06:00 imap1 kernel: [  165.585082] RPC:       rpc_release_client(ffff8800350d7000)
2016-03-11T03:22:10.777546-06:00 imap1 kernel: [  165.585092] RPC:   120 call_start nfs3 proc GETATTR (sync)
2016-03-11T03:22:10.777547-06:00 imap1 kernel: [  165.585094] RPC:   120 call_reserve (status 0)
2016-03-11T03:22:10.777548-06:00 imap1 kernel: [  165.585097] RPC:   120 call_reserveresult (status 0)
2016-03-11T03:22:10.777548-06:00 imap1 kernel: [  165.585099] RPC:   120 call_refresh (status 0)
2016-03-11T03:22:10.777549-06:00 imap1 kernel: [  165.585101] RPC:   120 call_refreshresult (status 0)
2016-03-11T03:22:10.777550-06:00 imap1 kernel: [  165.585103] RPC:   120 call_allocate (status 0)
2016-03-11T03:22:10.777551-06:00 imap1 kernel: [  165.585104] RPC:   120 call_bind (status 0)
2016-03-11T03:22:10.777551-06:00 imap1 kernel: [  165.585106] RPC:   120 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:22:10.777552-06:00 imap1 kernel: [  165.585108] RPC:   120 call_transmit (status 0)
2016-03-11T03:22:10.777553-06:00 imap1 kernel: [  165.585110] RPC:   120 rpc_xdr_encode (status 0)
2016-03-11T03:22:10.777554-06:00 imap1 kernel: [  165.585129] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:22:10.777555-06:00 imap1 kernel: [  165.585322] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:10.777555-06:00 imap1 kernel: [  165.585336] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:10.777556-06:00 imap1 kernel: [  165.585338] RPC:       reading TCP record fragment of length 112
2016-03-11T03:22:10.777557-06:00 imap1 kernel: [  165.585340] RPC:       reading XID (4 bytes)
2016-03-11T03:22:10.777557-06:00 imap1 kernel: [  165.585342] RPC:       reading reply for XID e5c8121a
2016-03-11T03:22:10.777559-06:00 imap1 kernel: [  165.585344] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:10.777559-06:00 imap1 kernel: [  165.585345] RPC:       read reply XID e5c8121a
2016-03-11T03:22:10.777560-06:00 imap1 kernel: [  165.585348] RPC:       XID e5c8121a read 104 bytes
2016-03-11T03:22:10.777561-06:00 imap1 kernel: [  165.585350] RPC:       xprt = ffff88003cfe4000, tcp_copied = 112, tcp_offset = 112, tcp_reclen = 112
2016-03-11T03:22:10.777561-06:00 imap1 kernel: [  165.585355] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:10.777562-06:00 imap1 kernel: [  165.585364] RPC:   120 call_status (status 112)
2016-03-11T03:22:10.777563-06:00 imap1 kernel: [  165.585366] RPC:   120 call_decode (status 112)
2016-03-11T03:22:10.777564-06:00 imap1 kernel: [  165.585369] RPC:   120 call_decode result 0
2016-03-11T03:22:10.777565-06:00 imap1 kernel: [  165.585373] RPC:       rpc_release_client(ffff8800350d7000)
2016-03-11T03:22:10.777566-06:00 imap1 kernel: [  165.585397] RPC:   121 call_start nfs3 proc READDIR (sync)
2016-03-11T03:22:10.777567-06:00 imap1 kernel: [  165.585399] RPC:   121 call_reserve (status 0)
2016-03-11T03:22:10.777567-06:00 imap1 kernel: [  165.585402] RPC:   121 call_reserveresult (status 0)
2016-03-11T03:22:10.777568-06:00 imap1 kernel: [  165.585403] RPC:   121 call_refresh (status 0)
2016-03-11T03:22:10.777569-06:00 imap1 kernel: [  165.585406] RPC:   121 call_refreshresult (status 0)
2016-03-11T03:22:10.777569-06:00 imap1 kernel: [  165.585408] RPC:   121 call_allocate (status 0)
2016-03-11T03:22:10.777570-06:00 imap1 kernel: [  165.585410] RPC:   121 call_bind (status 0)
2016-03-11T03:22:10.777571-06:00 imap1 kernel: [  165.585412] RPC:   121 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:22:10.777572-06:00 imap1 kernel: [  165.585413] RPC:   121 call_transmit (status 0)
2016-03-11T03:22:10.777572-06:00 imap1 kernel: [  165.585415] RPC:   121 rpc_xdr_encode (status 0)
2016-03-11T03:22:10.777573-06:00 imap1 kernel: [  165.585443] RPC:       xs_tcp_send_request(132) = 0
2016-03-11T03:22:10.797464-06:00 imap1 kernel: [  165.605841] RPC:       xs_tcp_data_ready...
2016-03-11T03:22:10.797475-06:00 imap1 kernel: [  165.605855] RPC:       xs_tcp_data_recv started
2016-03-11T03:22:10.797477-06:00 imap1 kernel: [  165.605857] RPC:       reading TCP record fragment of length 696
2016-03-11T03:22:10.797478-06:00 imap1 kernel: [  165.605859] RPC:       reading XID (4 bytes)
2016-03-11T03:22:10.797480-06:00 imap1 kernel: [  165.605861] RPC:       reading reply for XID e6c8121a
2016-03-11T03:22:10.797481-06:00 imap1 kernel: [  165.605863] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:22:10.797482-06:00 imap1 kernel: [  165.605865] RPC:       read reply XID e6c8121a
2016-03-11T03:22:10.797483-06:00 imap1 kernel: [  165.605868] RPC:       XID e6c8121a read 688 bytes
2016-03-11T03:22:10.797484-06:00 imap1 kernel: [  165.605870] RPC:       xprt = ffff88003cfe4000, tcp_copied = 696, tcp_offset = 696, tcp_reclen = 696
2016-03-11T03:22:10.797485-06:00 imap1 kernel: [  165.605876] RPC:       xs_tcp_data_recv done
2016-03-11T03:22:10.797486-06:00 imap1 kernel: [  165.605883] RPC:   121 call_status (status 696)
2016-03-11T03:22:10.797488-06:00 imap1 kernel: [  165.605885] RPC:   121 call_decode (status 696)
2016-03-11T03:22:10.797489-06:00 imap1 kernel: [  165.605888] RPC:   121 call_decode result 572
2016-03-11T03:22:10.797490-06:00 imap1 kernel: [  165.605892] RPC:       rpc_release_client(ffff8800350d7000)

I performed a failover, and while it was still down:
sudo ls /mnt/mail

2016-03-11T03:23:40.541543-06:00 imap1 kernel: [  255.351911] RPC:   122 call_start nfs3 proc GETATTR (sync)
2016-03-11T03:23:40.541551-06:00 imap1 kernel: [  255.351914] RPC:   122 call_reserve (status 0)
2016-03-11T03:23:40.541553-06:00 imap1 kernel: [  255.351917] RPC:   122 call_reserveresult (status 0)
2016-03-11T03:23:40.541554-06:00 imap1 kernel: [  255.351919] RPC:   122 call_refresh (status 0)
2016-03-11T03:23:40.541555-06:00 imap1 kernel: [  255.351922] RPC:   122 call_refreshresult (status 0)
2016-03-11T03:23:40.541556-06:00 imap1 kernel: [  255.351923] RPC:   122 call_allocate (status 0)
2016-03-11T03:23:40.541557-06:00 imap1 kernel: [  255.351924] RPC:   122 call_bind (status 0)
2016-03-11T03:23:40.541558-06:00 imap1 kernel: [  255.351926] RPC:   122 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:23:40.541559-06:00 imap1 kernel: [  255.351928] RPC:   122 call_transmit (status 0)
2016-03-11T03:23:40.541559-06:00 imap1 kernel: [  255.351929] RPC:   122 rpc_xdr_encode (status 0)
2016-03-11T03:23:40.541560-06:00 imap1 kernel: [  255.351959] RPC:       xs_tcp_send_request(112) = 0

At this point, the new server is sending TCP RSTs in response to the retransmissions. Eventually, the client starts a new TCP session and succeeds.

2016-03-11T03:24:40.549448-06:00 imap1 kernel: [  315.356111] RPC:   122 call_status (status -110)
2016-03-11T03:24:40.549475-06:00 imap1 kernel: [  315.356117] RPC:   122 call_timeout (minor)
2016-03-11T03:24:40.549477-06:00 imap1 kernel: [  315.356119] RPC:   122 call_bind (status 0)
2016-03-11T03:24:40.549478-06:00 imap1 kernel: [  315.356123] RPC:   122 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:24:40.549480-06:00 imap1 kernel: [  315.356125] RPC:   122 call_transmit (status 0)
2016-03-11T03:24:40.549481-06:00 imap1 kernel: [  315.356127] RPC:   122 rpc_xdr_encode (status 0)
2016-03-11T03:24:40.549483-06:00 imap1 kernel: [  315.356147] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:26:40.869474-06:00 imap1 kernel: [  435.676062] RPC:   122 call_status (status -110)
2016-03-11T03:26:40.869496-06:00 imap1 kernel: [  435.676067] RPC:   122 call_timeout (major)
2016-03-11T03:26:40.869498-06:00 imap1 kernel: [  435.676070] nfs: server 10.20.0.30 not responding, still trying
2016-03-11T03:26:40.869500-06:00 imap1 kernel: [  435.676073] RPC:   122 call_bind (status 0)
2016-03-11T03:26:40.869502-06:00 imap1 kernel: [  435.676075] RPC:   122 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:26:40.869503-06:00 imap1 kernel: [  435.676077] RPC:   122 call_transmit (status 0)
2016-03-11T03:26:40.869505-06:00 imap1 kernel: [  435.676080] RPC:   122 rpc_xdr_encode (status 0)
2016-03-11T03:26:40.869506-06:00 imap1 kernel: [  435.676091] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:27:24.897463-06:00 imap1 kernel: [  479.708050] RPC:       xs_error_report client ffff88003cfe4000, error=113...
2016-03-11T03:27:24.897483-06:00 imap1 kernel: [  479.708077] RPC:       xs_tcp_state_change client ffff88003cfe4000...
2016-03-11T03:27:24.897484-06:00 imap1 kernel: [  479.708083] RPC:       state 7 conn 1 dead 0 zapped 1 sk_shutdown 3
2016-03-11T03:27:24.897486-06:00 imap1 kernel: [  479.708098] RPC:   122 call_status (status -113)
2016-03-11T03:27:27.905960-06:00 imap1 kernel: [  482.716104] RPC:   122 call_timeout (minor)
2016-03-11T03:27:27.905983-06:00 imap1 kernel: [  482.716109] RPC:   122 call_bind (status 0)
2016-03-11T03:27:27.905985-06:00 imap1 kernel: [  482.716112] RPC:   122 call_connect xprt ffff88003cfe4000 is not connected
2016-03-11T03:27:27.905986-06:00 imap1 kernel: [  482.716117] RPC:       xs_connect delayed xprt ffff88003cfe4000 for 0 seconds
2016-03-11T03:27:27.905987-06:00 imap1 kernel: [  482.716120] RPC:       xs_tcp_state_change client ffff88003cfe4000...
2016-03-11T03:27:27.905988-06:00 imap1 kernel: [  482.716122] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
2016-03-11T03:27:27.905989-06:00 imap1 kernel: [  482.716144] RPC:   122 call_connect_status (status -11)
2016-03-11T03:27:27.905990-06:00 imap1 kernel: [  482.716146] RPC:   122 call_timeout (minor)
2016-03-11T03:27:27.905991-06:00 imap1 kernel: [  482.716147] RPC:   122 call_bind (status 0)
2016-03-11T03:27:27.905992-06:00 imap1 kernel: [  482.716149] RPC:   122 call_connect xprt ffff88003cfe4000 is not connected
2016-03-11T03:27:27.905992-06:00 imap1 kernel: [  482.716170] RPC:       xs_bind 0.0.0.0:960: ok (0)
2016-03-11T03:27:27.905993-06:00 imap1 kernel: [  482.716184] RPC:       worker connecting xprt ffff88003cfe4000 via tcp to 10.20.0.30 (port 2049)
2016-03-11T03:27:27.905995-06:00 imap1 kernel: [  482.716227] RPC:       ffff88003cfe4000 connect status 115 connected 0 sock state 2
2016-03-11T03:27:27.905996-06:00 imap1 kernel: [  482.716234] RPC:   122 call_connect_status (status -11)
2016-03-11T03:27:27.905996-06:00 imap1 kernel: [  482.716235] RPC:   122 call_timeout (minor)
2016-03-11T03:27:27.905997-06:00 imap1 kernel: [  482.716236] RPC:   122 call_bind (status 0)
2016-03-11T03:27:27.905998-06:00 imap1 kernel: [  482.716237] RPC:   122 call_connect xprt ffff88003cfe4000 is not connected
2016-03-11T03:27:27.905999-06:00 imap1 kernel: [  482.716511] RPC:       xs_tcp_state_change client ffff88003cfe4000...
2016-03-11T03:27:27.906000-06:00 imap1 kernel: [  482.716533] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
2016-03-11T03:27:27.906008-06:00 imap1 kernel: [  482.716635] RPC:   122 call_connect_status (status -11)
2016-03-11T03:27:27.906009-06:00 imap1 kernel: [  482.716637] RPC:   122 call_timeout (minor)
2016-03-11T03:27:27.906010-06:00 imap1 kernel: [  482.716639] RPC:   122 call_bind (status 0)
2016-03-11T03:27:27.906020-06:00 imap1 kernel: [  482.716640] RPC:   122 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:27:27.906022-06:00 imap1 kernel: [  482.716642] RPC:   122 call_transmit (status 0)
2016-03-11T03:27:27.906023-06:00 imap1 kernel: [  482.716643] RPC:   122 rpc_xdr_encode (status 0)
2016-03-11T03:27:27.906025-06:00 imap1 kernel: [  482.716672] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:27:27.915472-06:00 imap1 kernel: [  482.726023] RPC:       xs_tcp_data_ready...
2016-03-11T03:27:27.915482-06:00 imap1 kernel: [  482.726080] RPC:       xs_tcp_data_recv started
2016-03-11T03:27:27.915483-06:00 imap1 kernel: [  482.726083] RPC:       reading TCP record fragment of length 112
2016-03-11T03:27:27.915485-06:00 imap1 kernel: [  482.726085] RPC:       reading XID (4 bytes)
2016-03-11T03:27:27.915486-06:00 imap1 kernel: [  482.726088] RPC:       reading request with XID e7c8121a
2016-03-11T03:27:27.915487-06:00 imap1 kernel: [  482.726089] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:27:27.915488-06:00 imap1 kernel: [  482.726091] RPC:       read reply XID e7c8121a
2016-03-11T03:27:27.915489-06:00 imap1 kernel: [  482.726094] RPC:       XID e7c8121a read 104 bytes
2016-03-11T03:27:27.915490-06:00 imap1 kernel: [  482.726096] RPC:       xprt = ffff88003cfe4000, tcp_copied = 112, tcp_offset = 112, tcp_reclen = 112
2016-03-11T03:27:27.915492-06:00 imap1 kernel: [  482.726107] RPC:       xs_tcp_data_recv done
2016-03-11T03:27:27.918026-06:00 imap1 kernel: [  482.726187] RPC:   122 call_status (status 112)
2016-03-11T03:27:27.918032-06:00 imap1 kernel: [  482.726190] RPC:   122 call_decode (status 112)
2016-03-11T03:27:27.918033-06:00 imap1 kernel: [  482.726192] nfs: server 10.20.0.30 OK
2016-03-11T03:27:27.918034-06:00 imap1 kernel: [  482.726195] RPC:   122 call_decode result 0
2016-03-11T03:27:27.918035-06:00 imap1 kernel: [  482.726199] RPC:       rpc_release_client(ffff8800350d7000)
2016-03-11T03:27:27.918036-06:00 imap1 kernel: [  482.726210] RPC:   123 call_start nfs3 proc GETATTR (sync)
2016-03-11T03:27:27.918036-06:00 imap1 kernel: [  482.726211] RPC:   123 call_reserve (status 0)
2016-03-11T03:27:27.918037-06:00 imap1 kernel: [  482.726214] RPC:   123 call_reserveresult (status 0)
2016-03-11T03:27:27.918038-06:00 imap1 kernel: [  482.726215] RPC:   123 call_refresh (status 0)
2016-03-11T03:27:27.918038-06:00 imap1 kernel: [  482.726217] RPC:   123 call_refreshresult (status 0)
2016-03-11T03:27:27.918039-06:00 imap1 kernel: [  482.726218] RPC:   123 call_allocate (status 0)
2016-03-11T03:27:27.918039-06:00 imap1 kernel: [  482.726219] RPC:   123 call_bind (status 0)
2016-03-11T03:27:27.918040-06:00 imap1 kernel: [  482.726221] RPC:   123 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:27:27.918041-06:00 imap1 kernel: [  482.726222] RPC:   123 call_transmit (status 0)
2016-03-11T03:27:27.918042-06:00 imap1 kernel: [  482.726223] RPC:   123 rpc_xdr_encode (status 0)
2016-03-11T03:27:27.918042-06:00 imap1 kernel: [  482.726246] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:27:27.918043-06:00 imap1 kernel: [  482.726638] RPC:       xs_tcp_data_ready...
2016-03-11T03:27:27.918044-06:00 imap1 kernel: [  482.726650] RPC:       xs_tcp_data_recv started
2016-03-11T03:27:27.918044-06:00 imap1 kernel: [  482.726652] RPC:       reading TCP record fragment of length 112
2016-03-11T03:27:27.918045-06:00 imap1 kernel: [  482.726654] RPC:       reading XID (4 bytes)
2016-03-11T03:27:27.918046-06:00 imap1 kernel: [  482.726656] RPC:       reading reply for XID e8c8121a
2016-03-11T03:27:27.918046-06:00 imap1 kernel: [  482.726658] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:27:27.918047-06:00 imap1 kernel: [  482.726659] RPC:       read reply XID e8c8121a
2016-03-11T03:27:27.918048-06:00 imap1 kernel: [  482.726662] RPC:       XID e8c8121a read 104 bytes
2016-03-11T03:27:27.918048-06:00 imap1 kernel: [  482.726664] RPC:       xprt = ffff88003cfe4000, tcp_copied = 112, tcp_offset = 112, tcp_reclen = 112
2016-03-11T03:27:27.918049-06:00 imap1 kernel: [  482.726679] RPC:       xs_tcp_data_recv done
2016-03-11T03:27:27.918050-06:00 imap1 kernel: [  482.726710] RPC:   123 call_status (status 112)
2016-03-11T03:27:27.918051-06:00 imap1 kernel: [  482.726713] RPC:   123 call_decode (status 112)
2016-03-11T03:27:27.918052-06:00 imap1 kernel: [  482.726716] RPC:   123 call_decode result 0
2016-03-11T03:27:27.918053-06:00 imap1 kernel: [  482.726721] RPC:       rpc_release_client(ffff8800350d7000)
2016-03-11T03:27:27.918054-06:00 imap1 kernel: [  482.726768] RPC:   124 call_start nfs3 proc ACCESS (sync)
2016-03-11T03:27:27.918055-06:00 imap1 kernel: [  482.726770] RPC:   124 call_reserve (status 0)
2016-03-11T03:27:27.918055-06:00 imap1 kernel: [  482.726773] RPC:   124 call_reserveresult (status 0)
2016-03-11T03:27:27.918056-06:00 imap1 kernel: [  482.726775] RPC:   124 call_refresh (status 0)
2016-03-11T03:27:27.918057-06:00 imap1 kernel: [  482.726777] RPC:   124 call_refreshresult (status 0)
2016-03-11T03:27:27.918058-06:00 imap1 kernel: [  482.726779] RPC:   124 call_allocate (status 0)
2016-03-11T03:27:27.918059-06:00 imap1 kernel: [  482.726781] RPC:   124 call_bind (status 0)
2016-03-11T03:27:27.918060-06:00 imap1 kernel: [  482.726783] RPC:   124 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:27:27.918061-06:00 imap1 kernel: [  482.726785] RPC:   124 call_transmit (status 0)
2016-03-11T03:27:27.918061-06:00 imap1 kernel: [  482.726787] RPC:   124 rpc_xdr_encode (status 0)
2016-03-11T03:27:27.918062-06:00 imap1 kernel: [  482.726814] RPC:       xs_tcp_send_request(116) = 0
2016-03-11T03:27:27.918064-06:00 imap1 kernel: [  482.727066] RPC:       xs_tcp_data_ready...
2016-03-11T03:27:27.918064-06:00 imap1 kernel: [  482.727077] RPC:       xs_tcp_data_recv started
2016-03-11T03:27:27.918065-06:00 imap1 kernel: [  482.727079] RPC:       reading TCP record fragment of length 120
2016-03-11T03:27:27.918066-06:00 imap1 kernel: [  482.727080] RPC:       reading XID (4 bytes)
2016-03-11T03:27:27.918066-06:00 imap1 kernel: [  482.727082] RPC:       reading reply for XID e9c8121a
2016-03-11T03:27:27.918067-06:00 imap1 kernel: [  482.727084] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:27:27.918069-06:00 imap1 kernel: [  482.727086] RPC:       read reply XID e9c8121a
2016-03-11T03:27:27.918070-06:00 imap1 kernel: [  482.727088] RPC:       XID e9c8121a read 112 bytes
2016-03-11T03:27:27.918070-06:00 imap1 kernel: [  482.727090] RPC:       xprt = ffff88003cfe4000, tcp_copied = 120, tcp_offset = 120, tcp_reclen = 120
2016-03-11T03:27:27.918071-06:00 imap1 kernel: [  482.727104] RPC:       xs_tcp_data_recv done
2016-03-11T03:27:27.918072-06:00 imap1 kernel: [  482.727183] RPC:   124 call_status (status 120)
2016-03-11T03:27:27.918073-06:00 imap1 kernel: [  482.727186] RPC:   124 call_decode (status 120)
2016-03-11T03:27:27.918074-06:00 imap1 kernel: [  482.727189] RPC:   124 call_decode result 0
2016-03-11T03:27:27.918075-06:00 imap1 kernel: [  482.727194] RPC:       rpc_release_client(ffff8800350d7000)
2016-03-11T03:27:27.918076-06:00 imap1 kernel: [  482.727204] RPC:   125 call_start nfs3 proc GETATTR (sync)
2016-03-11T03:27:27.918076-06:00 imap1 kernel: [  482.727206] RPC:   125 call_reserve (status 0)
2016-03-11T03:27:27.918077-06:00 imap1 kernel: [  482.727209] RPC:   125 call_reserveresult (status 0)
2016-03-11T03:27:27.918079-06:00 imap1 kernel: [  482.727210] RPC:   125 call_refresh (status 0)
2016-03-11T03:27:27.918080-06:00 imap1 kernel: [  482.727213] RPC:   125 call_refreshresult (status 0)
2016-03-11T03:27:27.918080-06:00 imap1 kernel: [  482.727215] RPC:   125 call_allocate (status 0)
2016-03-11T03:27:27.918081-06:00 imap1 kernel: [  482.727216] RPC:   125 call_bind (status 0)
2016-03-11T03:27:27.918082-06:00 imap1 kernel: [  482.727219] RPC:   125 call_connect xprt ffff88003cfe4000 is connected
2016-03-11T03:27:27.918083-06:00 imap1 kernel: [  482.727220] RPC:   125 call_transmit (status 0)
2016-03-11T03:27:27.918084-06:00 imap1 kernel: [  482.727222] RPC:   125 rpc_xdr_encode (status 0)
2016-03-11T03:27:27.918085-06:00 imap1 kernel: [  482.727250] RPC:       xs_tcp_send_request(112) = 0
2016-03-11T03:27:27.918086-06:00 imap1 kernel: [  482.727499] RPC:       xs_tcp_data_ready...
2016-03-11T03:27:27.918086-06:00 imap1 kernel: [  482.727509] RPC:       xs_tcp_data_recv started
2016-03-11T03:27:27.918087-06:00 imap1 kernel: [  482.727512] RPC:       reading TCP record fragment of length 112
2016-03-11T03:27:27.918088-06:00 imap1 kernel: [  482.727513] RPC:       reading XID (4 bytes)
2016-03-11T03:27:27.918090-06:00 imap1 kernel: [  482.727515] RPC:       reading reply for XID eac8121a
2016-03-11T03:27:27.918091-06:00 imap1 kernel: [  482.727517] RPC:       reading CALL/REPLY flag (4 bytes)
2016-03-11T03:27:27.918091-06:00 imap1 kernel: [  482.727518] RPC:       read reply XID eac8121a
2016-03-11T03:27:27.918092-06:00 imap1 kernel: [  482.727520] RPC:       XID eac8121a read 104 bytes
2016-03-11T03:27:27.918093-06:00 imap1 kernel: [  482.727523] RPC:       xprt = ffff88003cfe4000, tcp_copied = 112, tcp_offset = 112, tcp_reclen = 112
2016-03-11T03:27:27.918094-06:00 imap1 kernel: [  482.727536] RPC:       xs_tcp_data_recv done
2016-03-11T03:27:27.918095-06:00 imap1 kernel: [  482.727613] RPC:   125 call_status (status 112)
2016-03-11T03:27:27.918096-06:00 imap1 kernel: [  482.727616] RPC:   125 call_decode (status 112)
2016-03-11T03:27:27.918097-06:00 imap1 kernel: [  482.727619] RPC:   125 call_decode result 0
2016-03-11T03:27:27.918097-06:00 imap1 kernel: [  482.727623] RPC:       rpc_release_client(ffff8800350d7000)

-- 
Richard
