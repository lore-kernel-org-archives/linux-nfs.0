From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Mon, 8 Mar 2010 11:16:07 +0100
Message-ID: <20100308101607.GR19154@ics.muni.cz>
References: <4B7D4E55.4040002@RedHat.com> <20100304201941.GL19154@ics.muni.cz>
	<4B9021EF.60309@oracle.com> <20100304212149.GM19154@ics.muni.cz>
	<4B903485.1030608@oracle.com> <20100304224011.GN19154@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20100304224011.GN19154@ics.muni.cz>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

it appears that gssd fails to run with nfs-utils-1.2.2.

It is terminated by signal SIGSEGV.

Program received signal SIGSEGV, Segmentation fault.
0x00007ffff70a3ace in ?? () from /usr/lib/libgssglue.so.1
(gdb) where
#0  0x00007ffff70a3ace in ?? () from /usr/lib/libgssglue.so.1
#1  0x00007ffff70a6781 in gss_set_allowable_enctypes ()
   from /usr/lib/libgssglue.so.1
#2  0x0000000000408793 in limit_krb5_enctypes (sec=3D0x7fffffffddf0, uid=3D=
0)
    at krb5_util.c:336
#3  0x0000000000407215 in create_auth_rpc_client (clp=3D0x617c10, =

    clnt_return=3D0x7fffffffe2f0, auth_return=3D0x7fffffffe2e8, uid=3D0, au=
thtype=3D0)
    at gssd_proc.c:801
#4  0x0000000000407896 in process_krb5_upcall (clp=3D0x617c10, uid=3D0, fd=
=3D13, =

    tgtname=3D0x0, service=3D0x0) at gssd_proc.c:978
#5  0x0000000000408052 in handle_gssd_upcall (clp=3D0x617c10) at
gssd_proc.c:1215
#6  0x0000000000404e21 in scan_poll_results (ret=3D1) at gssd_main_loop.c:82
#7  0x0000000000405442 in gssd_run () at gssd_main_loop.c:230
#8  0x0000000000404d47 in main (argc=3D2, argv=3D0x7fffffffe638) at gssd.c:=
187


-- =

Luk=E1=B9 Hejtm=E1nek
