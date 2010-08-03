Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:38568
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932271Ab0HCPwq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 11:52:46 -0400
Date: Tue, 3 Aug 2010 17:45:56 +0200
From: Michael Guntsche <mike@it-loops.com>
To: linux-nfs@vger.kernel.org
Subject: Kerberos auth Problem with nfs3/4
Message-ID: <20100803154556.GA6262@gibson.comsick.at>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I recently tried re-enabling a kerberos setup here after running with
sec=sys for a while. Now the problem is that mount the export with
sec=krb5 just hangs.

To rule everything out I tried mount from the server itself.

mount gibson:/export /mnt

The mount just hangs and does not return.
This is happening on a debian sid system with nfs-utils 1.2.2 installed.

rpc.svcgssd -vvf:
=================
entering poll
leaving poll
handling null request
sname = nfs/gibson.comsick.at@COMSICK.AT
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length
8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1280885973 (35783 from
now), clnt: nfs@gibson.comsick.at, uid: -1, gid: -1, num aux grps: 0:
sending null reply
finished handling null request
entering poll

rpc.gssd -vvf:
==============
beginning poll
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt1b
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt1a
handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt1c)
handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt1c)
process_krb5_upcall: service is '<null>'
Successfully obtained machine credentials for principal
'nfs/gibson.comsick.at@COMSICK.AT' stored in ccache
'FILE:/tmp/krb5cc_machine_COMSICK.AT'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_COMSICK.AT' are good
until 1280886246
using FILE:/tmp/krb5cc_machine_COMSICK.AT as credentials cache for
machine creds
using environment variable to select krb5 ccache
FILE:/tmp/krb5cc_machine_COMSICK.AT
creating context using fsuid 0 (save_uid 0)
creating tcp client for server gibson.comsick.at
DEBUG: port already set to 2049
creating context with server nfs@gibson.comsick.at
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length
8
doing downcall

After that nothing. the same setup worked a while ago but of course both
the kernel and the nfs-utils have been updated in the meantime. I tried
this both with nfs3 and nfs4. 

Please tell me if you need further information to help me debug this
problem.

Kind regards,
Michael
