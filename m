From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] nfs(5): Replace the term "netid" in mount option descriptions
Date: Tue, 23 Sep 2008 12:46:19 -0400
Message-ID: <76bd70e30809230946x35442235w8374145dc7b76022@mail.gmail.com>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net>
	 <20080923161636.5119.54434.stgit@manray.1015granger.net>
	 <RTPCLUEXC1-PRDC8wSA000000ca@RTPMVEXC1-PRD.hq.netapp.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:10879 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbYIWQqW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2008 12:46:22 -0400
Received: by gv-out-0910.google.com with SMTP id e6so160358gvc.37
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2008 09:46:20 -0700 (PDT)
In-Reply-To: <RTPCLUEXC1-PRDC8wSA000000ca-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2008 at 12:30 PM, Talpey, Thomas
<Thomas.Talpey@netapp.com> wrote:
> To be pedantic, identifiying this field as a "prot" may be just as
> misleading. For example "rdma" (which isn't mentioned btw ;-) )
> can employ tcp - iWARP adapters do this.

The Solaris mount_nfs man page puts it this way:

  proto=netid | rdma

Language for rdma support is yet to be added to nfs(5).

> I think instead that the proto= field simply names the "transport"
> rather than "netid" or "prot". Also, I think "prot" is much too easily
> mistaken for "port".

Was looking for a short word to use in the option's synopsis instead
of "netid" or "n".  How about "name" instead of "prot" ?

> So I suggest changing the example to "proto=transport", and deleting
> the word "protocol" in the text, simply leaving "the transport used by
> NFS to transmit..."

I don't have any objection to that.  Anyone else have an opinion?

> At 12:16 PM 9/23/2008, Chuck Lever wrote:
>>Mike Eisler noted that the use of the term "netid" in the descriptions
>>of the "proto=" option is not appropriate, since Linux does not allow
>>"udp6" or "tcp6".
>>
>>Remove the term "netid" from nfs(5).
>>
>>Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>---
>>
>> utils/mount/nfs.man |   12 ++++++------
>> 1 files changed, 6 insertions(+), 6 deletions(-)
>>
>>diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>>index 0fc5079..b1037a8 100644
>>--- a/utils/mount/nfs.man
>>+++ b/utils/mount/nfs.man
>>@@ -411,10 +411,10 @@ for mounting the
>> .B nfs
>> file system type.
>> .TP 1.5i
>>-.BI proto= netid
>>+.BI proto= prot
>> The transport protocol used by the NFS client
>> to transmit requests to the NFS server for this mount point.
>>-.I netid
>>+.I prot
>> can be either
>> .B udp
>> or
>>@@ -489,11 +489,11 @@ or the server's mountd service is not available
>>on the advertised port.
>> This option can be used when mounting an NFS server
>> through a firewall that blocks the rpcbind protocol.
>> .TP 1.5i
>>-.BI mountproto= netid
>>+.BI mountproto= prot
>> The transport protocol used by the NFS client
>> to transmit requests to the NFS server's mountd service when performing
>> this mount request, and when later unmounting this mount point.
>>-.I netid
>>+.I prot
>> can be either
>> .B udp
>> or
>>@@ -638,10 +638,10 @@ for mounting the
>> .B nfs4
>> file system type.
>> .TP 1.5i
>>-.BI proto= netid
>>+.BI proto= prot
>> The transport protocol used by the NFS client
>> to transmit requests to the NFS server for this mount point.
>>-.I netid
>>+.I prot
>> can be either
>> .B udp
>> or
>>
>>--
>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
"If you simplify your English, you are freed from the worst follies of
orthodoxy."
 -- George Orwell
