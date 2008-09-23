From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] nfs(5): Clarify behavior of the mountproto= and proto= options
Date: Tue, 23 Sep 2008 12:55:52 -0400
Message-ID: <76bd70e30809230955l66aa59abo1fa25f85994e1915@mail.gmail.com>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net>
	 <20080923161641.5119.37034.stgit@manray.1015granger.net>
	 <RTPCLUEXC1-PRDSzbAU000000cd@RTPMVEXC1-PRD.hq.netapp.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.185]:9701 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbYIWQzy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2008 12:55:54 -0400
Received: by gv-out-0910.google.com with SMTP id e6so162652gvc.37
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2008 09:55:52 -0700 (PDT)
In-Reply-To: <RTPCLUEXC1-PRDSzbAU000000cd-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2008 at 12:41 PM, Talpey, Thomas
<Thomas.Talpey@netapp.com> wrote:
> One other comment...
>
> At 12:16 PM 9/23/2008, Chuck Lever wrote:
>>Document the interaction between the mountproto= and the proto= mount
>>options in a new subsection of nfs(5).
>>
>>Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>---
>>
>> utils/mount/nfs.man |   81 +++++++++++++++++++++++++++++++++++++++++++++++++++
>> 1 files changed, 81 insertions(+), 0 deletions(-)
>>
>>diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>>index b1037a8..48f2153 100644
>>--- a/utils/mount/nfs.man
>>+++ b/utils/mount/nfs.man
>>@@ -831,6 +831,87 @@ and
>> .B wsize
>> can safely be allowed to default to the largest values supported by
>> both client and server, independent of the network's MTU size.
>>+.SS "Interaction between the proto and mountproto options"
>>+The Linux NFS client can use a different transport protocol for
>>+contacting an NFS server's rpcbind service, its mountd service,
>>+its NLM service, and its NFS service.
>>+The exact transport protocols employed by the Linux NFS client for
>>+each mount point depends on the settings of the transport protocol
>>+mount options, which include
>>+.BR proto ,
>>+.BR mountproto ,
>>+.BR udp ", and " tcp .
>>+.P
>>+The NSM protocol uses the UDP transport
>>+no matter what transport specific options are specified.
>
> This actually isn't true - in fact the client NSM by default listens on
> both UDP and TCP, as can be seen with rpcinfo -p.
>
> What is true is that the vast majority of NFS servers call back on UDP,
> and if this fails, there is no indication at the client whatsoever.
>
> So the text should perhaps say "NFS servers typically choose UDP for the
> NSM protocol; the client in any case accepts both UDP and TCP."

Granted that this text should be tuned a bit, but...

Even though rpc.statd listens on TCP as well, Linux sm-notify requests
go out only on UDP; and there is no mount option to change any of this
behavior.

NSM is a bit of a challenge to describe because both ends act as a
client and a server.

--
Chuck Lever
