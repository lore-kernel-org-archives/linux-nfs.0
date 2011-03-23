Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:37479 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249Ab1CWO3n convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 10:29:43 -0400
Received: by qwk3 with SMTP id 3so5961867qwk.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 07:29:42 -0700 (PDT)
In-Reply-To: <4D89D36D.3090207@interlinx.bc.ca>
References: <imbb8m$uiv$1@dough.gmane.org>
	<AANLkTimFJ2fMn805jY91u8FQihib8GfJ=8S7Yy4y47R3@mail.gmail.com>
	<4D89D36D.3090207@interlinx.bc.ca>
Date: Wed, 23 Mar 2011 10:29:41 -0400
Message-ID: <AANLkTi=b1z0MrYYQmidbra0EHanegcLO5qoOScLq21rb@mail.gmail.com>
Subject: Re: different kernels mean NFS4/GSSAPI works or doesn't
From: Kevin Coffman <kwc@citi.umich.edu>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 23, 2011 at 7:03 AM, Brian J. Murrell <brian@interlinx.bc.ca> wrote:
> On 11-03-22 10:41 PM, Kevin Coffman wrote:
>> Hi Brian,
>
> Hi Kevin,
>
>> Can you tell me how you removed the 3des keys from the keytab?  (If
>> you simply used ktutil, this isn't good enough.  The KDC will still
>> issue a ticket with 3DES because, as far as it knows, the service
>> still has a 3des key in the KDC and supports 3des.)
>
> Ahh.  Well, I did use ktutil.  I opened the keytabs (/etc/krb5.keytab on
> both the client and server) then while they were open in ktutil, removed
> the files from the respective filesystems, deleted the keys in ktutil
> then wrote it back out from ktutil to the filesystem.
>
> But you say this is not good enough, yes?  Should I be removing keys
> from the KDC also?
>
> kadmin.local:  getprinc nfs/pc.example.com@ILINX
> Principal: nfs/pc.example.com@ILINX
> Expiration date: [never]
> Last password change: Sun Mar 14 20:51:08 EDT 2010
> Password expiration date: [none]
> Maximum ticket life: 0 days 10:00:00
> Maximum renewable life: 7 days 00:00:00
> Last modified: Sun Mar 14 20:51:08 EDT 2010 (brian/admin@ILINX)
> Last successful authentication: Sat Mar 19 11:39:41 EDT 2011
> Last failed authentication: [never]
> Failed password attempts: 0
> Number of keys: 2
> Key: vno 2, Triple DES cbc mode with HMAC/sha1, no salt
> Key: vno 2, DES cbc mode with CRC-32, no salt
> MKey: vno 1
> Attributes: REQUIRES_PRE_AUTH
> Policy: [none]
>
> and/or
>
> kadmin.local:  getprinc nfs/linux.example.com@ILINX
> Principal: nfs/linux.example.com@ILINX
> Expiration date: [never]
> Last password change: Sat Nov 01 00:37:11 EDT 2008
> Password expiration date: [none]
> Maximum ticket life: 0 days 10:00:00
> Maximum renewable life: 7 days 00:00:00
> Last modified: Sat Nov 01 00:37:11 EDT 2008 (root/admin@ILINX)
> Last successful authentication: [never]
> Last failed authentication: [never]
> Failed password attempts: 0
> Number of keys: 1
> Key: vno 4, DES cbc mode with CRC-32, no salt
> MKey: vno 1
> Attributes:
> Policy: [none]
>
> Ahhhh.  But it seems that the server doesn't have a 3des key in the KDC,
> only the client does.

Which should be fine unless there is some callback stuff going.  In
that case, the NFS client becomes a server and its keytab would need
to have only a des key as well.  You would need to re-issue the client
machine's keytab on the KDC with only a des key.  See
http://www.citi.umich.edu/projects/nfsv4/linux/krb5-setup.html

However, that doesn't appear to be the case from looking at the
gssd/svcgssd output.  Have you checked the server's syslog for
messages about rpc.gssd not running?  (That would indicate it is
trying to initiate a callback and the upcall is failing because
rpc.gssd is not running on the NFS server.)  I don't recall that
situation causing the mount to hang though.

>> (Sorry if this was already provided and I missed it.)
>
> No, I don't think we have been here yet.
>
>> Do you have
>> output from gssd and svcgssd in the original failure/hang case?
>
> Here they are:
>
> pc# rpc.gssd with the -f -vvv
> beginning poll
> handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt4b90)
> handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
> handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt4b90)
> process_krb5_upcall: service is '<null>'
> Full hostname for 'linux.example.com' is 'linux.example.com'
> Full hostname for 'pc' is 'pc'
> Key table entry not found while getting keytab entry for 'root/pc@ILINX'
> Key table entry not found while getting keytab entry for 'nfs/pc@ILINX'
> Key table entry not found while getting keytab entry for 'host/pc@ILINX'
> Success getting keytab entry for nfs/*@ILINX
> Successfully obtained machine credentials for principal
> 'nfs/pc.example.com@ILINX' stored in ccache 'FILE:/tmp/krb5cc_machine_ILINX'
> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_ILINX' are good until
> 1300913838
> using FILE:/tmp/krb5cc_machine_ILINX as credentials cache for machine creds
> using environment variable to select krb5 ccache
> FILE:/tmp/krb5cc_machine_ILINX
> creating context using fsuid 0 (save_uid 0)
> creating tcp client for server linux.example.com
> DEBUG: port already set to 2049
> creating context with server nfs@linux.example.com
> DEBUG: serialize_krb5_ctx: lucid version!
> prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> doing downcall
>
> linux# /usr/sbin/rpc.svcgssd -f -vvv
> entering poll
> leaving poll
> handling null request
> sname = nfs/pc.example.com@ILINX
> DEBUG: serialize_krb5_ctx: lucid version!
> prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> doing downcall
> mech: krb5, hndl len: 4, ctx len 85, timeout: 1300913838 (35999 from
> now), uid: -1, gid: -1, num aux grps: 0:
> sending null reply
> writing message: \x \x60...99 0 0 \x01000000 \x60......b2
> finished handling null request
> entering poll
>
> pc# mount -t nfs4 -o sec=krb5 linux.example.com:/tmp /mnt/tmp
> [hung/blocked]
>
> I don't know if the contents of the "writing message: " were important
> but I also don't know if there is sensitive information in it or not, so
> being cautious, I did some redacting.  Please let me know if that's a
> problem.
>
> All of the above is with my original keytabs, before 3des key removal.
>
> Cheers,
> b.
>
>

OK.  Thanks.  There is enough info there, even with the redaction.

> prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8

This shows that a des (enctype 4) session key is being negotiated and
delivered to both kernels, so I don't think any of the Kerberos issues
should be involved here.  (At least from the user-land perspective.)

I'm not sure what kernel change would be causing your hang ...

K.C.
