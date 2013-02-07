Return-Path: linux-nfs-owner@vger.kernel.org
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:54164 "EHLO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422669Ab3BGWzV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 17:55:21 -0500
Received: by mail-ie0-f177.google.com with SMTP id 16so4139428iea.8
        for <linux-nfs@vger.kernel.org>; Thu, 07 Feb 2013 14:55:20 -0800 (PST)
Message-ID: <511430D6.2060603@noaa.gov>
Date: Thu, 07 Feb 2013 15:55:18 -0700
From: Nathan Dauchy <nathan.dauchy@noaa.gov>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: v3 client processes hung in rpc_wait_bit_killable
References: <CAO9q2D=aFEABgy98EazNuoP9f+0LdMa2Aw1SUwCXc8gAkZchcQ@mail.gmail.com>
In-Reply-To: <CAO9q2D=aFEABgy98EazNuoP9f+0LdMa2Aw1SUwCXc8gAkZchcQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update: we had another similar hang and this time I caught it fairly
quickly, so the "netstat -atu" output may be more useful.  See inline
below...

On 01/31/2013 03:58 PM, Nathan Dauchy - NOAA Affiliate wrote:
> Greetings,
> 
> On our Linux HPC cluster, one or more of the client nodes occasionally
> has a problem with all access to an NFS mount hanging.  Can anyone
> here point out a possible cause of the symptoms below or offer
> suggestions for other tools or debugging steps I should try?  Any new
> ideas or hints are appreciated!
> 
> The basic symptom is that all processes which access the NFS file
> system hang in "D" state.  Dumping the call trace shows that they are
> stuck in rpc_wait_bit_killable().  The processes can indeed be
> terminated with "kill -9".  If I kill all hung processes, I can umount
> the file system and remount it and then access works again.
> 
> We can run under "normal" user load for up to 3 days before 1-5 client
> nodes experience a similar problem.   When it happens, the 100's of
> other clients show no sign of a problem with their NFS mounts.  There
> is no pattern to exactly which client will hang, though one complex
> user workflow seems to trigger it more than others.
> 
> Here is an example of the hung processes:
> 
> # ps -eo pid,stat,args,wchan | grep D
>    PID STAT COMMAND                     WCHAN
>   2192 Ds   -bash                       rpc_wait_bit_killable
>   2408 Ds   bash -c /home/ndauchy/bin/f rpc_wait_bit_killable
>  15926 D    df -P                       rpc_wait_bit_killable
>  36857 S+   grep D                      pipe_wait
> 
> By running "df" on each NFS mount one by one I was able to narrow down
> which mount was hung to this one:
> 
> # mount | grep home
> 10.178.17.21:/vol/home on /misc/whome type nfs
> (rw,relatime,vers=3,rsize=8192,wsize=8192,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.178.17.21,mountvers=3,mountport=4046,mountproto=udp,local_lock=all,addr=10.178.17.21)
> 
> There is no TCP connection to that server that I can see:
> 
> # netstat -atu
> Active Internet connections (servers and established)
> Proto Recv-Q Send-Q Local Address               Foreign Address    State
> tcp        0      0 *:ssh                       *:*               LISTEN
> tcp        0      0 s320-ib0:panasas            *:*               LISTEN
> tcp        0      0 s320:panasas                *:*               LISTEN
> tcp        0      0 *:15002                     *:*               LISTEN
> tcp        0      0 *:15003                     *:*               LISTEN
> tcp        0      0 localhost.localdomain:15005 *:*               LISTEN
> tcp        0      0 s320-ib0:45637              panmgmt5:10622    ESTABLISHED
> tcp        0      0 s320:ssh                    fe3:59631         ESTABLISHED
> tcp        0      0 s320:849                    wms1314-nfs:nfs   ESTABLISHED
> tcp        0      0 s320:ssh                    fe5:47363         ESTABLISHED
> tcp        0      0 *:ssh                       *:*               LISTEN
> udp        0      0 s320-ib0:ntp                *:*
> udp        0      0 s320:ntp                    *:*
> udp        0      0 localhost.localdomain:ntp   *:*
> udp        0      0 *:ntp                       *:*
> udp        0      0 *:52539                     *:*
> udp        0      0 fe80::21e:6703:3c:f00d:ntp  *:*
> udp        0      0 fe80::21e:67ff:fe3c:f008:ntp *:*
> udp        0      0 ::1:ntp                     *:*
> udp        0      0 *:ntp                       *:*

This time there is still no connection to the NFS server, but there are
many conections in CLOSE_WAIT and FIN_WAIT.:

# netstat -atu
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address               Foreign Address
    State
tcp        0      0 *:ssh                       *:*
    LISTEN
tcp        0      0 n109-ib0:panasas            *:*
    LISTEN
tcp        0      0 n109:panasas                *:*
    LISTEN
tcp        0      0 *:15002                     *:*
    LISTEN
tcp        0      0 *:15003                     *:*
    LISTEN
tcp        0      0 n109:15003                  n98:975
    SYN_RECV
tcp        0      0 n109:15003                  n12:nnsp
    SYN_RECV
tcp        0      0 n109:15003                  n7:timbuktu
    SYN_RECV
tcp        0      0 n109:15003                  n56:netsc-prod
    SYN_RECV
tcp        0      0 n109:15003                  n58:at-echo
    SYN_RECV
tcp        0      0 n109:15003                  n116:815
    SYN_RECV
tcp        0      0 n109:15003                  n73:1001
    SYN_RECV
tcp        0      0 n109:15003                  n5:768
    SYN_RECV
tcp        0      0 n109:15003                  n83:276
    SYN_RECV
tcp        0      0 n109:15003                  n10:867
    SYN_RECV
tcp        0      0 n109:15003                  n23:csi-sgwp
    SYN_RECV
tcp        0      0 n109:15003                  n48:ticf-1
    SYN_RECV
tcp        0      0 localhost.localdomain:15005 *:*
    LISTEN
tcp        0     86 n109:932                    n131:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n99:nest-protocol
    CLOSE_WAIT
tcp       79      0 n109:15003                  n9:macon-tcp
    CLOSE_WAIT
tcp       79      0 n109:15003                  n131:cvc_hostd
    CLOSE_WAIT
tcp        0     86 n109:331                    n11:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n75:963
    CLOSE_WAIT
tcp       79      0 n109:15003                  n98:openport
    CLOSE_WAIT
tcp       79      0 n109:15003                  n9:ipcserver
    CLOSE_WAIT
tcp        1      0 n109:15003                  n93:979
    CLOSE_WAIT
tcp       79      0 n109:15003                  n126:820
    CLOSE_WAIT
tcp       79      0 n109:15003                  n121:at-7
    CLOSE_WAIT
tcp       79      0 n109:15003                  n45:sift-uft
    CLOSE_WAIT
tcp       79      0 n109:15003                  n121:scc-security
    CLOSE_WAIT
tcp       81      0 n109:15003                  n30:229
    CLOSE_WAIT
tcp        0     86 n109:utmpcd                 n16:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n95:241
    CLOSE_WAIT
tcp        0     89 n109:zserv                  n145:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n116:878
    CLOSE_WAIT
tcp       79      0 n109:15003                  n93:vmnet
    CLOSE_WAIT
tcp       79      0 n109:15003                  n10:960
    CLOSE_WAIT
tcp       79      0 n109:15003                  n140:sntp-heartbeat
    CLOSE_WAIT
tcp       79      0 n109:15003                  n45:nas
    CLOSE_WAIT
tcp        0     86 n109:rmc                    n55:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n103:ddm-rdb
    CLOSE_WAIT
tcp       79      0 n109:15003                  n77:philips-vc
    CLOSE_WAIT
tcp       79      0 n109:15003                  n85:883
    CLOSE_WAIT
tcp       81      0 n109:15003                  n52:con
    CLOSE_WAIT
tcp        0     86 n109:vacdsm-sws             n36:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n73:iiop
    CLOSE_WAIT
tcp        0     88 n109:946                    n5:15003
    FIN_WAIT1
tcp        0     86 n109:sgcp                   n108:15003
    FIN_WAIT1
tcp       80      0 n109:15003                  n145:iris-lwz
    CLOSE_WAIT
tcp       79      0 n109:15003                  n66:885
    CLOSE_WAIT
tcp       81      0 n109:15003                  n7:pawserv
    CLOSE_WAIT
tcp       80      0 n109:15003                  n53:opalis-rdv
    CLOSE_WAIT
tcp       81      0 n109:15003                  n115:hap
    CLOSE_WAIT
tcp       79      0 n109:15003                  n65:remotefs
    CLOSE_WAIT
tcp       81      0 n109:15003                  n118:914c/g
    CLOSE_WAIT
tcp       79      0 n109:15003                  n11:sgcp
    CLOSE_WAIT
tcp       79      0 n109:15003                  n131:mftp
    CLOSE_WAIT
tcp       79      0 n109:15003                  n65:3com-amp3
    CLOSE_WAIT
tcp       79      0 n109:15003                  n101:vatp
    CLOSE_WAIT
tcp       79      0 n109:15003                  n66:mftp
    CLOSE_WAIT
tcp       81      0 n109:15003                  n7:708
    CLOSE_WAIT
tcp       81      0 n109:15003                  n115:iso-ill
    CLOSE_WAIT
tcp       80      0 n109:15003                  n47:864
    CLOSE_WAIT
tcp       79      0 n109:15003                  n41:uma
    CLOSE_WAIT
tcp       79      0 n109:15003                  n6:vnas
    CLOSE_WAIT
tcp       79      0 n109:15003                  n49:exp1
    CLOSE_WAIT
tcp        0      0 n109-ib0:56970              panmgmt5:panasas
    TIME_WAIT
tcp       79      0 n109:15003                  n36:732
    CLOSE_WAIT
tcp        0      0 n109:919                    n19:15003
    FIN_WAIT2
tcp       81      0 n109:15003                  n5:corerjd
    CLOSE_WAIT
tcp       80      0 n109:15003                  n53:at-5
    CLOSE_WAIT
tcp       79      0 n109:15003                  n83:namp
    CLOSE_WAIT
tcp        1      0 n109:ssh                    n145:36357
    CLOSE_WAIT
tcp       79      0 n109:15003                  n127:917
    CLOSE_WAIT
tcp       79      0 n109:15003                  n11:vpps-qua
    CLOSE_WAIT
tcp       79      0 n109:15003                  n8:rlzdbase
    CLOSE_WAIT
tcp       81      0 n109:15003                  n118:zserv
    CLOSE_WAIT
tcp       79      0 n109:15003                  n49:telnets
    CLOSE_WAIT
tcp       81      0 n109:15003                  n52:cadlock
    CLOSE_WAIT
tcp       79      0 n109:15003                  n41:texar
    CLOSE_WAIT
tcp       79      0 n109:15003                  n58:937
    CLOSE_WAIT
tcp        0     88 n109:hassle                 n43:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n47:entrust-kmsh
    CLOSE_WAIT
tcp        0      1 n109:prm-nm                 n93:15003
    SYN_SENT
tcp        0      0 n109:1017                   wms56-nfs:nfs
    ESTABLISHED
tcp       79      0 n109:15003                  n23:asip-webadmin
    CLOSE_WAIT
tcp       79      0 n109:15003                  n99:879
    CLOSE_WAIT
tcp       79      0 n109:15003                  n101:jargon
    CLOSE_WAIT
tcp       79      0 n109:15003                  n62:snare
    CLOSE_WAIT
tcp        0      0 n109:ssh                    fe5:42381
    ESTABLISHED
tcp       79      0 n109:15003                  n6:iris-xpc
    CLOSE_WAIT
tcp       79      0 n109:15003                  n16:931
    CLOSE_WAIT
tcp       79      0 n109:15003                  n103:urm
    CLOSE_WAIT
tcp       79      0 n109:15003                  n49:mftp
    CLOSE_WAIT
tcp       79      0 n109:15003                  n98:npmp-gui
    CLOSE_WAIT
tcp        0     86 n109:981                    n48:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n36:telnets
    CLOSE_WAIT
tcp       81      0 n109:15003                  n68:asa
    CLOSE_WAIT
tcp       79      0 n109:15003                  n11:npmp-gui
    CLOSE_WAIT
tcp       81      0 n109:15003                  n5:813
    CLOSE_WAIT
tcp       79      0 n109:15003                  n116:avian
    CLOSE_WAIT
tcp       79      0 n109:15003                  n127:new-rwho
    CLOSE_WAIT
tcp       79      0 n109:15003                  n9:ulistproc
    CLOSE_WAIT
tcp       79      0 n109:15003                  n75:k-block
    CLOSE_WAIT
tcp       79      0 n109:15003                  n26:819
    CLOSE_WAIT
tcp       79      0 n109:15003                  n37:vpps-qua
    CLOSE_WAIT
tcp       79      0 n109:15003                  n6:qrh
    CLOSE_WAIT
tcp        0     86 n109:bgmp                   n65:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n101:bnet
    CLOSE_WAIT
tcp       79      0 n109:15003                  n62:unify
    CLOSE_WAIT
tcp       79      0 n109:15003                  n140:microsoft-ds
    CLOSE_WAIT
tcp       80      0 n109:15003                  n145:ocs_cmu
    CLOSE_WAIT
tcp       79      0 n109:15003                  n81:decbsrv
    CLOSE_WAIT
tcp       81      0 n109:15003                  n5:ddm-dfm
    CLOSE_WAIT
tcp       79      0 n109:15003                  n81:decauth
    CLOSE_WAIT
tcp       79      0 n109:15003                  n26:1002
    CLOSE_WAIT
tcp       81      0 n109:15003                  n118:lanserver
    CLOSE_WAIT
tcp       81      0 n109:15003                  n118:mac-srvr-admin
    CLOSE_WAIT
tcp       79      0 n109:15003                  n8:852
    CLOSE_WAIT
tcp       79      0 n109:15003                  n41:hassle
    CLOSE_WAIT
tcp       79      0 n109:15003                  n37:743
    CLOSE_WAIT
tcp       80      0 n109:15003                  n145:olsr
    CLOSE_WAIT
tcp       81      0 n109:15003                  n120:bhfhs
    CLOSE_WAIT
tcp       79      0 n109:15003                  n101:pkix-timestamp
    CLOSE_WAIT
tcp       79      0 n109:15003                  n56:298
    CLOSE_WAIT
tcp       79      0 n109:15003                  n86:970
    CLOSE_WAIT
tcp       79      0 n109:15003                  n10:netconf-ssh
    CLOSE_WAIT
tcp       81      0 n109:15003                  n122:netrcs
    CLOSE_WAIT
tcp       79      0 n109:15003                  n95:34617
    CLOSE_WAIT
tcp       23      0 n109:15002                  jetbqs3:818
    CLOSE_WAIT
tcp       79      0 n109:15003                  n86:hp-collector
    CLOSE_WAIT
tcp       79      0 n109:15003                  n62:815
    CLOSE_WAIT
tcp       81      0 n109:15003                  n122:sanity
    CLOSE_WAIT
tcp       80      0 n109:15003                  n145:krb5_prop
    CLOSE_WAIT
tcp       81      0 n109:15003                  n7:passgo
    CLOSE_WAIT
tcp       79      0 n109:15003                  n81:839
    CLOSE_WAIT
tcp       79      0 n109:15003                  n16:939
    CLOSE_WAIT
tcp       81      0 n109:15003                  n5:338
    CLOSE_WAIT
tcp        0     86 n109:335                    n45:15003
    FIN_WAIT1
tcp       52      0 n109:15002                  jetbqs3:845
    ESTABLISHED
tcp       79      0 n109:15003                  n86:923
    CLOSE_WAIT
tcp        0      0 n109-ib0:58388              panmgmt4:panasas
    TIME_WAIT
tcp       81      0 n109:15003                  n7:urm
    CLOSE_WAIT
tcp       79      0 n109:15003                  n106:matip-type-a
    CLOSE_WAIT
tcp       79      0 n109:15003                  n48:928
    CLOSE_WAIT
tcp       79      0 n109:15003                  n56:utime
    CLOSE_WAIT
tcp       79      0 n109:15003                  n11:nest-protocol
    CLOSE_WAIT
tcp       79      0 n109:15003                  n65:imaps
    CLOSE_WAIT
tcp       79      0 n109:15003                  n23:725
    CLOSE_WAIT
tcp       79      0 n109:15003                  n127:datasurfsrvsec
    CLOSE_WAIT
tcp       79      0 n109:15003                  n37:quotad
    CLOSE_WAIT
tcp       79      0 n109:15003                  n55:hello-port
    CLOSE_WAIT
tcp       79      0 n109:15003                  n26:289
    CLOSE_WAIT
tcp       79      0 n109:15003                  n75:opalis-rdv
    CLOSE_WAIT
tcp        0      0 n109:45677                  10.178.123.66:10622
    ESTABLISHED
tcp       79      0 n109:15003                  n15:820
    CLOSE_WAIT
tcp       79      0 n109:15003                  n121:341
    CLOSE_WAIT
tcp       80      0 n109:15003                  n53:spsc
    CLOSE_WAIT
tcp        0     86 n109:hap                    n23:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n85:fln-spx
    CLOSE_WAIT
tcp       79      0 n109:15003                  n127:decvms-sysmgt
    CLOSE_WAIT
tcp       79      0 n109:15003                  n106:dn6-nlm-aud
    CLOSE_WAIT
tcp       79      0 n109:15003                  n10:sco-websrvrmg3
    CLOSE_WAIT
tcp       79      0 n109:15003                  n131:link
    CLOSE_WAIT
tcp       79      0 n109:15003                  n6:818
    CLOSE_WAIT
tcp       79      0 n109:15003                  n126:863
    CLOSE_WAIT
tcp       79      0 n109:15003                  n126:servstat
    CLOSE_WAIT
tcp        0     87 n109:commerce               n53:15003
    FIN_WAIT1
tcp       79      0 n109:15003                  n16:decauth
    CLOSE_WAIT
tcp       79      0 n109:15003                  n41:xact-backup
    CLOSE_WAIT
tcp        0      0 n109-ib0:60283              panmgmt6:panasas
    TIME_WAIT
tcp       79      0 n109:15003                  n85:spsc
    CLOSE_WAIT
tcp       79      0 n109:15003                  n75:banyan-rpc
    CLOSE_WAIT
tcp        0      0 *:ssh                       *:*
    LISTEN
udp        0      0 *:60495                     *:*

udp        0      0 *:863                       *:*

udp        0      0 n109-ib0:ntp                *:*

udp        0      0 n109:ntp                    *:*

udp        0      0 localhost.localdomain:ntp   *:*

udp        0      0 *:ntp                       *:*

udp        0      0 fe80::230:48ff:fec9:3b5e:ntp *:*

udp        0      0 fe80::230:48c9:78dc:1:ntp   *:*

udp        0      0 ::1:ntp                     *:*

udp        0      0 *:ntp                       *:*



> 
> Here are the call traces:
> 
> # echo w > /proc/sysrq-trigger
> 
> SysRq : Show Blocked State
>   task                        PC stack   pid father
> bash          D 0000000000000000     0  2192      1 0x00000004
>  ffff88042db47b28 0000000000000082 0000000000000000 ffff880400000000
>  ffff88042db47ad8 ffff88042db47dd8 ffff88042db47b98 ffff88042db47b88
>  ffff880121f7d098 ffff88042db47fd8 000000000000fb88 ffff880121f7d098
> Call Trace:
>  [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
>  [<ffffffffa000b972>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
>  [<ffffffff814feaaf>] __wait_on_bit+0x5f/0x90
>  [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
>  [<ffffffff814feb58>] out_of_line_wait_on_bit+0x78/0x90
>  [<ffffffff81092110>] ? wake_bit_function+0x0/0x50
>  [<ffffffffa0000480>] ? call_reserve+0x0/0x60 [sunrpc]
>  [<ffffffffa000beb5>] __rpc_execute+0xf5/0x350 [sunrpc]
>  [<ffffffff81091f97>] ? bit_waitqueue+0x17/0xd0
>  [<ffffffffa000c171>] rpc_execute+0x61/0xa0 [sunrpc]
>  [<ffffffffa0002385>] rpc_run_task+0x75/0x90 [sunrpc]
>  [<ffffffffa00024a2>] rpc_call_sync+0x42/0x70 [sunrpc]
>  [<ffffffffa00c396d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs]
>  [<ffffffffa00c4707>] nfs3_proc_getattr+0x47/0x90 [nfs]
>  [<ffffffffa00b23b3>] __nfs_revalidate_inode+0xe3/0x220 [nfs]
>  [<ffffffffa00b2696>] nfs_revalidate_inode+0x36/0x60 [nfs]
>  [<ffffffffa00b2776>] nfs_getattr+0x66/0x120 [nfs]
>  [<ffffffff81180571>] vfs_getattr+0x51/0x80
>  [<ffffffff81180600>] vfs_fstatat+0x60/0x80
>  [<ffffffff8118074b>] vfs_stat+0x1b/0x20
>  [<ffffffff81180774>] sys_newstat+0x24/0x50
>  [<ffffffff8117cba5>] ? fput+0x25/0x30
>  [<ffffffff811785cd>] ? filp_close+0x5d/0x90
>  [<ffffffff811786a5>] ? sys_close+0xa5/0x100
>  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> bash          D 0000000000000000     0  2408      1 0x00000000
>  ffff8802f1f4d898 0000000000000086 0000000000000082 0000000000000246
>  ffff8802f1f4d838 ffff8802f1f4d898 ffff880028043718 0000000300000001
>  ffff88043418b098 ffff8802f1f4dfd8 000000000000fb88 ffff88043418b098
> Call Trace:
>  [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
>  [<ffffffffa000b972>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
>  [<ffffffff814feaaf>] __wait_on_bit+0x5f/0x90
>  [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
>  [<ffffffff814feb58>] out_of_line_wait_on_bit+0x78/0x90
>  [<ffffffff81092110>] ? wake_bit_function+0x0/0x50
>  [<ffffffffa0000480>] ? call_reserve+0x0/0x60 [sunrpc]
>  [<ffffffffa000beb5>] __rpc_execute+0xf5/0x350 [sunrpc]
>  [<ffffffff81091f97>] ? bit_waitqueue+0x17/0xd0
>  [<ffffffffa000c171>] rpc_execute+0x61/0xa0 [sunrpc]
>  [<ffffffffa0002385>] rpc_run_task+0x75/0x90 [sunrpc]
>  [<ffffffffa00024a2>] rpc_call_sync+0x42/0x70 [sunrpc]
>  [<ffffffffa00c396d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs]
>  [<ffffffffa00c3d4c>] nfs3_proc_access+0xbc/0x180 [nfs]
>  [<ffffffffa00ab168>] nfs_do_access+0x198/0x420 [nfs]
>  [<ffffffffa000e765>] ? generic_lookup_cred+0x15/0x20 [sunrpc]
>  [<ffffffffa000d770>] ? rpcauth_lookupcred+0x70/0xc0 [sunrpc]
>  [<ffffffffa00ab498>] nfs_permission+0xa8/0x1e0 [nfs]
>  [<ffffffff8118995d>] __link_path_walk+0xad/0x1030
>  [<ffffffff8118ab6a>] path_walk+0x6a/0xe0
>  [<ffffffff8118ad3b>] do_path_lookup+0x5b/0xa0
>  [<ffffffff8117c780>] ? get_empty_filp+0xa0/0x180
>  [<ffffffff8118bc6b>] do_filp_open+0xfb/0xd60
>  [<ffffffffa00af26a>] ? nfs_file_read+0xca/0x130 [nfs]
>  [<ffffffff81213426>] ? security_prepare_creds+0x16/0x20
>  [<ffffffff810996ef>] ? prepare_creds+0x8f/0xb0
>  [<ffffffff81183943>] open_exec+0x33/0x100
>  [<ffffffff81183aff>] do_execve+0xef/0x340
>  [<ffffffff8127ea8a>] ? strncpy_from_user+0x4a/0x90
>  [<ffffffff810095ea>] sys_execve+0x4a/0x80
>  [<ffffffff8100b54a>] stub_execve+0x6a/0xc0
> df            D 0000000000000000     0 15926  15915 0x00000000
>  ffff8801898f5ae8 0000000000000082 ffff8801898f5a48 ffffffff81116967
>  ffff8801898f5a68 ffffffff81116a25 ffff88032d29cdc0 ffffffffa00207a0
>  ffff88042be765f8 ffff8801898f5fd8 000000000000fb88 ffff88042be765f8
> Call Trace:
>  [<ffffffff81116967>] ? mempool_free_slab+0x17/0x20
>  [<ffffffff81116a25>] ? mempool_free+0x95/0xa0
>  [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
>  [<ffffffffa000b972>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
>  [<ffffffff814feaaf>] __wait_on_bit+0x5f/0x90
>  [<ffffffffa000b930>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
>  [<ffffffff814feb58>] out_of_line_wait_on_bit+0x78/0x90
>  [<ffffffff81092110>] ? wake_bit_function+0x0/0x50
>  [<ffffffffa0000480>] ? call_reserve+0x0/0x60 [sunrpc]
>  [<ffffffffa000beb5>] __rpc_execute+0xf5/0x350 [sunrpc]
>  [<ffffffff81091f97>] ? bit_waitqueue+0x17/0xd0
>  [<ffffffffa000c171>] rpc_execute+0x61/0xa0 [sunrpc]
>  [<ffffffffa0002385>] rpc_run_task+0x75/0x90 [sunrpc]
>  [<ffffffffa00024a2>] rpc_call_sync+0x42/0x70 [sunrpc]
>  [<ffffffff8118a018>] ? __link_path_walk+0x768/0x1030
>  [<ffffffffa00c396d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs]
>  [<ffffffffa00c4797>] nfs3_proc_statfs+0x47/0x90 [nfs]
>  [<ffffffffa00b4cc6>] nfs_statfs+0x66/0x1a0 [nfs]
>  [<ffffffff811abe64>] statfs_by_dentry+0x74/0xa0
>  [<ffffffff811abf9b>] vfs_statfs+0x1b/0xb0
>  [<ffffffff811ac260>] do_statfs_native+0x20/0xb0
>  [<ffffffff811ac3f2>] sys_statfs+0x72/0xb0
>  [<ffffffff81500a7e>] ? do_device_not_available+0xe/0x10
>  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> 

New traces look fairly similar:

SysRq : Show Blocked State
  task                        PC stack   pid father
sshd          D 0000000000000000     0 23812   1786 0x00000004
 ffff88032c5af928 0000000000000082 0000000000000000 0000000000000003
 0000000000000001 0000000000000282 ffff88032c5af8d8 ffffffff81052223
 ffff88031b1cdab8 ffff88032c5affd8 000000000000fb88 ffff88031b1cdab8
Call Trace:
 [<ffffffff81052223>] ? __wake_up+0x53/0x70
 [<ffffffffa000b710>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffffa000b752>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
 [<ffffffff814ead9f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa000b710>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffff814eae48>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff810909d0>] ? wake_bit_function+0x0/0x50
 [<ffffffffa0000480>] ? call_reserve+0x0/0x60 [sunrpc]
 [<ffffffffa000bc95>] __rpc_execute+0xf5/0x350 [sunrpc]
 [<ffffffff81090857>] ? bit_waitqueue+0x17/0xd0
 [<ffffffffa000bf51>] rpc_execute+0x61/0xa0 [sunrpc]
 [<ffffffffa0002385>] rpc_run_task+0x75/0x90 [sunrpc]
 [<ffffffffa00024a2>] rpc_call_sync+0x42/0x70 [sunrpc]
 [<ffffffffa00c129d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs]
 [<ffffffffa00c167c>] nfs3_proc_access+0xbc/0x180 [nfs]
 [<ffffffff81195540>] ? mntput_no_expire+0x30/0x110
 [<ffffffffa00a91b9>] nfs_do_access+0x199/0x3c0 [nfs]
 [<ffffffffa000e575>] ? generic_lookup_cred+0x15/0x20 [sunrpc]
 [<ffffffffa000d550>] ? rpcauth_lookupcred+0x70/0xc0 [sunrpc]
 [<ffffffffa00a9488>] nfs_permission+0xa8/0x1e0 [nfs]
 [<ffffffff8118497d>] __link_path_walk+0xad/0x1030
 [<ffffffff81185b8a>] path_walk+0x6a/0xe0
 [<ffffffff81185d5b>] do_path_lookup+0x5b/0xa0
 [<ffffffff81177a50>] ? get_empty_filp+0xa0/0x180
 [<ffffffff81186c8b>] do_filp_open+0xfb/0xd60
 [<ffffffff81193272>] ? alloc_fd+0x92/0x160
 [<ffffffff81173a39>] do_sys_open+0x69/0x140
 [<ffffffff81088a2a>] ? sys_setresuid+0x15a/0x180
 [<ffffffff81173b50>] sys_open+0x20/0x30
 [<ffffffff8100b072>] system_call_fastpath+0x16/0x1b
bash          D 0000000000000000     0 24454      1 0x00000000
 ffff8802e8163898 0000000000000082 0000000000000000 0000000000000282
 0000000000000082 0000000000000000 ffff8802e8163848 ffff8802e81638a8
 ffff8803306885f8 ffff8802e8163fd8 000000000000fb88 ffff8803306885f8
Call Trace:
 [<ffffffffa000b710>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffffa000b752>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
 [<ffffffff814ead9f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa000b710>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
 [<ffffffff814eae48>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff810909d0>] ? wake_bit_function+0x0/0x50
 [<ffffffffa0000480>] ? call_reserve+0x0/0x60 [sunrpc]
 [<ffffffffa000bc95>] __rpc_execute+0xf5/0x350 [sunrpc]
 [<ffffffff81090857>] ? bit_waitqueue+0x17/0xd0
 [<ffffffffa000bf51>] rpc_execute+0x61/0xa0 [sunrpc]
 [<ffffffffa0002385>] rpc_run_task+0x75/0x90 [sunrpc]
 [<ffffffffa00024a2>] rpc_call_sync+0x42/0x70 [sunrpc]
 [<ffffffffa00c129d>] nfs3_rpc_wrapper.clone.0+0x3d/0xd0 [nfs]
 [<ffffffffa00c167c>] nfs3_proc_access+0xbc/0x180 [nfs]
 [<ffffffff81195540>] ? mntput_no_expire+0x30/0x110
 [<ffffffffa00a91b9>] nfs_do_access+0x199/0x3c0 [nfs]
 [<ffffffffa000e575>] ? generic_lookup_cred+0x15/0x20 [sunrpc]
 [<ffffffffa000d550>] ? rpcauth_lookupcred+0x70/0xc0 [sunrpc]
 [<ffffffffa00a9488>] nfs_permission+0xa8/0x1e0 [nfs]
 [<ffffffff8118497d>] __link_path_walk+0xad/0x1030
 [<ffffffff81185b8a>] path_walk+0x6a/0xe0
 [<ffffffff81185d5b>] do_path_lookup+0x5b/0xa0
 [<ffffffff81177a50>] ? get_empty_filp+0xa0/0x180
 [<ffffffff81186c8b>] do_filp_open+0xfb/0xd60
 [<ffffffff8104338c>] ? __do_page_fault+0x1ec/0x480
 [<ffffffff8120cbe6>] ? security_prepare_creds+0x16/0x20
 [<ffffffff8117ea23>] open_exec+0x33/0x100
 [<ffffffff8117ebbf>] do_execve+0xcf/0x2c0
 [<ffffffff810095ea>] sys_execve+0x4a/0x80
 [<ffffffff8100b4ca>] stub_execve+0x6a/0xc0


Does any of that provide more clues?

Are there other diagnostic tools I should be using?

Anything else I should check before rebooting the client?


Thanks in advance,
Nathan


> 
> When I tried "echo 1 > /proc/sys/sunrpc/rpc_debug" I got MANY messages
> like the following, so quickly set it back to 0 again.  I don't know
> how to tell whether the RPCs are for the hung mountpoint or a
> different one on the client, but did notice that the "xid" numbers are
> increasing, but the "req" number does not change.
> 
> Jan 31 01:13:11 s320 kernel: RPC: 55738 xprt_prepare_transmit
> Jan 31 01:13:13 s320 kernel: RPC: 55743 reserved req ffff88042be25000
> xid 4041e127
> Jan 31 01:13:13 s320 kernel: RPC: 55743 xprt_prepare_transmit
> Jan 31 01:13:13 s320 kernel: RPC: 55743 xprt_transmit(112)
> Jan 31 01:13:13 s320 kernel: RPC: 55743 xmit complete
> Jan 31 01:13:13 s320 kernel: RPC: 55743 xid 4041e127 complete (112
> bytes received)
> Jan 31 01:13:13 s320 kernel: RPC: 55743 release request ffff88042be25000
> Jan 31 01:13:13 s320 kernel: RPC: 55744 reserved req ffff88042be25000
> xid 4141e127
> Jan 31 01:13:13 s320 kernel: RPC: 55744 xprt_prepare_transmit
> Jan 31 01:13:13 s320 kernel: RPC: 55744 xprt_transmit(112)
> Jan 31 01:13:13 s320 kernel: RPC: 55744 xmit complete
> Jan 31 01:13:13 s320 kernel: RPC: 55744 xid 4141e127 complete (112
> bytes received)
> Jan 31 01:13:13 s320 kernel: RPC: 55744 release request ffff88042be25000
> Jan 31 01:13:14 s320 kernel: RPC: 55745 reserved req ffff88042be25000
> xid 4241e127
> Jan 31 01:13:14 s320 kernel: RPC: 55745 xprt_prepare_transmit
> Jan 31 01:13:14 s320 kernel: RPC: 55745 xprt_transmit(116)
> Jan 31 01:13:14 s320 kernel: RPC: 55745 xmit complete
> Jan 31 01:13:14 s320 kernel: RPC: 55745 xid 4241e127 complete (120
> bytes received)
> Jan 31 01:13:14 s320 kernel: RPC: 55745 release request ffff88042be25000
> Jan 31 01:13:14 s320 kernel: RPC: 55746 reserved req ffff88042be25000
> xid 4341e127
> Jan 31 01:13:14 s320 kernel: RPC: 55746 xprt_prepare_transmit
> Jan 31 01:13:14 s320 kernel: RPC: 55746 xprt_transmit(116)
> Jan 31 01:13:14 s320 kernel: RPC: 55746 xmit complete
> Jan 31 01:13:14 s320 kernel: RPC: 55746 xid 4341e127 complete (120
> bytes received)
> Jan 31 01:13:14 s320 kernel: RPC: 55746 release request ffff88042be25000
> Jan 31 01:13:14 s320 kernel: RPC: 55747 reserved req ffff88042be25000
> xid 4441e127
> 
> 
> The clients are running CentOS-6.3, and we have tried both kernel
> 2.6.32-279.2.1.el6 and 2.6.32-279.19.1.el6, and are using
> nfs-utils-1.2.3-26.el6.  We never saw the problem on the same hardware
> when running CentOS-5.5 and kernel 2.6.18-194.11.4.el5.
> 
> The server in this example is a NetApp FAS3140, but mounts to other
> servers (primarily running CentOS-5.7) have exhibited similar
> problems.
> 
> Running "tcpdump" shows no NFS traffic to the server when running a
> new command which should access the NFS mount.
> 
> We do not have a firewall in the way, and I don't believe that any
> other routing problems are blocking network traffic since "ping" and
> "showmount -e" from the client to the server respond normally.
> 
> Trying to create a new mount to any mountpoint on the same server
> hangs as well.  The call trace shows it in __d_instantiate(), called
> from rpc_wait_bit_killable().  Creating a new mount to a different
> server works fine.
> 
> And finally, here are even more details that may be unique to our
> configuration, and might confuse the issue, but I wanted to list them
> here just in case they are relevant:
> 
> * These nodes are fully diskless, mounting their root file system via
> NFS, and have no swap.
> 
> * We see similar hangs of processes accessing the root file system, as
> indicated by the call trace generated by alt-sysrq-w from the console.
> Unfortunately without a working root file system I can't login to the
> nodes to get more debugging info, so have decided to concentrate on
> the /home mount described above.
> 
> * Our site has 5 clusters all running the exact same (diskless) OS,
> ranging from 250 to 850 nodes.  The problem is triggered most
> frequently on a system with 8 cores/node + 24 GB memory, and very
> rarely on one with 16 cores/node + 32 GB memory.  So it may have
> something to do with memory pressure or with number of nodes used by a
> user's application at a fixed core count.  Of course I can't rule out
> differences in client NIC or cluster network capabilities impacting
> frequency either.
> 
> 
> Thanks for your time reading all this and any help you can offer!
> 
> -Nathan
