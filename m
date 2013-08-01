Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362Ab3HAVGf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 17:06:35 -0400
Subject: Re: Trouble with kerberized NFS client after upgrading from
 nfs-utils 1.2.0 to 1.2.5
From: Simo Sorce <simo@redhat.com>
To: Rohit Kumar Mehta <rohitm@engr.uconn.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <51FAC933.40508@engr.uconn.edu>
References: <51FAC933.40508@engr.uconn.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Aug 2013 17:06:32 -0400
Message-ID: <1375391193.15733.213.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-08-01 at 16:46 -0400, Rohit Kumar Mehta wrote:
> Hello everyone, I am stuck trying to figure out why I cannot get 
> sec=krb5 Linux clients working after upgrading from Ubuntu 10.04 LTS 
> (Lucid) to 12.04 (Precise)
> 
> I suspect the same problem is with the newer nfs-utils, but cannot be sure.
> 
> On the old (working) Lucid system, I think the important software is:
> # dpkg -l |grep nfs-common
> ii  nfs-common 1:1.2.0-4ubuntu4.2                              NFS 
> support files common to client and serve
> # uname -a
> Linux cselin3 2.6.32-29-generic #58-Ubuntu SMP Fri Feb 11 20:52:10 UTC 
> 2011 x86_64 GNU/Linux
> 
> And on the newer (sec=krb5 mounts fail) system, the important software is:
> # dpkg -l |grep nfs-common
> ii  nfs-common 1:1.2.5-3ubuntu3.1                      NFS support files 
> common to client and server
> # uname -a
> Linux c27-00 3.2.0-51-generic #77-Ubuntu SMP Wed Jul 24 20:18:19 UTC 
> 2013 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> The NFS server we are using is a Hitachi BlueARC, and like I said, older 
> Linux clients work fine.  After upgrading to new kernel and
> 
> nfs-utils, any attempt to mount yields an error:
> # mount hnas.engr.uconn.edu:/EngrUser/users/rohitm /foo -o sec=krb5
> mount.nfs: access denied by server while mounting 
> hnas.engr.uconn.edu:/EngrUser/users/rohitm
> 
> I've reproduced the same behavior with both -t nfs4 and -t nfs. (Both 
> nfsv3 and nfsv4 work with kerberos security in our configuration with 
> Lucid, but not Precise)  I've checked the Kerberos credential cache:
> 
> root@c27-00:~# klist -e -f -c /tmp/krb5cc_machine_ENGR.UCONN.EDU
> Ticket cache: FILE:/tmp/krb5cc_machine_ENGR.UCONN.EDU
> Default principal: nfs/c27-00.engr.uconn.edu@ENGR.UCONN.EDU
> 
> Valid starting    Expires           Service principal
> 01/08/2013 15:40  02/08/2013 01:40 krbtgt/ENGR.UCONN.EDU@ENGR.UCONN.EDU
>      renew until 02/08/2013 15:40, Flags: FRI
>      Etype (skey, tkt): des3-cbc-sha1, des3-cbc-sha1
> 01/08/2013 15:40  02/08/2013 01:40 nfs/hnas.engr.uconn.edu@ENGR.UCONN.EDU
>      renew until 02/08/2013 15:40, Flags: FRT
>      Etype (skey, tkt): des3-cbc-sha1, des3-cbc-sha1
> 
> I also have rpc.idmapd and rpc.gssd running with extra verbosity.  I 
> don't see anything blatantly wrong.  This looks slightly suspicious:
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: creating tcp client for server 
> hnas.engr.uconn.edu
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: DEBUG: port already set to 2049
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: creating context with server 
> nfs@hnas.engr.uconn.edu
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: WARNING: Failed to create krb5 
> context for user with uid 0 for server hnas.engr.uconn.edu
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: WARNING: Failed to create machine 
> krb5 context with credentials cache 
> FILE:/tmp/krb5cc_machine_ENGR.UCONN.EDU for server hnas.engr.uconn.edu
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: WARNING: Failed to create machine 
> krb5 context with any credentials cache for server hnas.engr.uconn.edu
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: doing error downcall
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: dir_notify_handler: sig 37 si 
> 0x7fffdf0135b0 data 0x7fffdf013480
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: dir_notify_handler: sig 37 si 
> 0x7fffdf0135b0 data 0x7fffdf013480
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: dir_notify_handler: sig 37 si 
> 0x7fffdf0134f0 data 0x7fffdf0133c0
> Aug  1 16:32:50  rpc.gssd[780]: last message repeated 4 times
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: destroying client 
> /run/rpc_pipefs/nfs/clnt5
> Aug  1 16:32:50 c27-00 rpc.gssd[780]: destroying client 
> /run/rpc_pipefs/nfs/clnt4
> 
> I am able to successfuly get the nfs principal for the client from 
> /etc/krb5.keytab "nfs/c27-00.engr.uconn.edu" and I can see the principal 
> for the server "nfs/hnas.engr.uconn.edu" in cache 
> /tmp/krb5cc_machine_ENGR.UCONN.EDU.
> 
> I appreciate any advice or assistance.  Thanks in advance!
> Rohit

Was libtirpc also updated ?
There has beena  change recently where we eliminated the use of
libgssglue and you will get issues if both nfs-utils and libtirpc are
not compiled to use the same gssapi library.

Please post ldd output on rpc.gssd and libtirpc.so to verify if this is
the issue.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

