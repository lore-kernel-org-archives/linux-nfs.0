From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH_V7 0/12] NFSv4 find client fix Version 7
Date: Tue, 4 Jan 2011 16:01:16 -0500
Message-ID: <EF4E9447-046D-4840-B7F1-5D5391A97F67@netapp.com>
References: <1294173766-5573-1-git-send-email-andros@netapp.com> <20110104205713.GA7908@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, bfields@redhat.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751205Ab1ADVBv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 16:01:51 -0500
In-Reply-To: <20110104205713.GA7908@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 4, 2011, at 3:57 PM, J. Bruce Fields wrote:

> On Tue, Jan 04, 2011 at 03:42:34PM -0500, andros@netapp.com wrote:
>> 
>> 
>> Version 7 of these patches
>> Applies to Tronds nfs-for-next branch
>> 
>> Already acked by bfields
>> ------------------------
>> 0001-SUNRPC-move-svc_drop-to-caller-of-svc_process_common.patch
>> 0002-SUNRPC-fix-bc_send-print.patch
>> 0010-NFS-RPC_AUTH_GSS-unsupported-on-v4.1-back-channel.patch
>> 0012-NFS-rename-client-back-channel-transport-field.patch
> 
> In future, if you don't mind actually adding the "Acked-by"'s to those
> patches with your signed-off-by's, that'll help remind me which ones
> I've read before as I'm looking through them....
> 
> (Well, unless you've changed them in some non-trivial way and want me to
> reread them.)

Sure.

-->Andy

> 
> --b.
> 
>> 
>> Responded to Version 6 comments from bfields.
>> ---------------------------------------------
>> 0003-SUNRPC-new-transport-for-the-NFSv4.1-shared-back-cha.patch
>> 0004-NFS-register-and-unregister-back-channel-transport.patch
>> 
>> Unchanged:
>> ----------
>> 0005-NFS-use-svc_create_xprt-for-NFSv4.1-callback-service.patch
>> 0006-NFS-do-not-clear-minor-version-at-nfs_client-free.patch
>> 0007-NFS-implement-v4.0-callback_ident.patch
>> 0008-NFS-associate-sessionid-with-callback-connection.patch
>> 0009-NFS-refactor-nfs_find_client-and-reference-client-ac.patch
>> 0011-NFS-add-session-back-channel-draining.patch
>> 
>> 
>> The back channel server svc_process_common RPC layer pg_authenticate call
>> [nfs_callback_authenticate] is shared by both the NFSv4.0 and the NFSv4.1
>> callback threads. It authenticates the incoming request by finding (and
>> referencing) an nfs_client struct based on the incoming request address
>> and the NFS version (4). This is akin to the NFS server which authenticates
>> requests by matching the server address to the exports file client list.
>> 
>> Since there is no minorversion in the search, it may find the wrong
>> nfs_client struct. For the nfsv4.0 callback service thread, this means it
>> could find an NFSv4.1 nfs_client. For the NFSv4.1 callback service thread, it
>> could find an NFSv4.0 instead of v4.1, or find an NFSv4.1 nfs_client with the
>> wrong session.
>> 
>> The nfs_client is dereferenced at the end of pg_authenticate. Another
>> nfs_find_client call is done in the NFS layouer per operation dispatcher
>> routines for NFSv4.0 and in the cb_sequence operation dispatcher routine for
>> NFSv4.1 after decoding.
>> 
>> This means the callback server could start processing a callback, passing
>> the pg_authenticate test, and have the nfs_client struct freed between the
>> pg_authenticate call and the dispatcher operation call. Or, it could have
>> found the wrong nfs_client in the pg_authenticate call.
>> 
>> The current code has this behavior: If the nfs_client is not found in
>> pg_authenticate, the request is simply dropped (SVC_DROP). If an nfs_client
>> is not found in the dispatcher routines NFS4ERR_BADSESSION is returned for
>> v4.1 requests and NFS4ERR_BADHANDLE for v4.0 requests.
>> 
>> The fix is to implement the v4.0 SETCLIENTID callback_ident and use it to find
>> the one and only client for v4.0 callbacks, and to associate the sessionid
>> with the sessions based callback service (v4.1) and use it to identify the
>> one and only client. This can be done in the NFS layer, in CB_COMPOUND header
>> processing for v4.0 and in CB_SEQUENCE processing in v4.1.
>> In both cases, a reference to the found client is held across CB_COMPOUND
>> processing.
>> 
>> The pg_authenticate method does not have the callback_ident for CB_NULL or
>> CB_COMPOUND v4.0 processing, so just the server address, nfsversion and
>> minorversion is used for the client search
>> 
>> For sessions based callback service, the sessionID can't be set until the
>> return of the CREATE_SESSION call, yet the CB_NULL ping from a server can
>> be initiated by the server at the receipt of the CREATE_SESSION call before
>> the response is sent. So for CB_NULL, the sessionid is (usually) not set, and
>> the sessionid is not used for CB_NULL pg_authenticate client searches.
>> 
>> -->Andy
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

