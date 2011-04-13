Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21145 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932379Ab1DMUmn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 16:42:43 -0400
Message-ID: <4DA60AB9.1050104@netapp.com>
Date: Wed, 13 Apr 2011 16:42:33 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Jiri Slaby <jslaby@suse.cz>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
        akpm@linux-foundation.org, mm-commits@vger.kernel.org,
        ML netdev <netdev@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>	 <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org>	 <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz>	 <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz>	 <4DA48EB0.40600@netapp.com>  <4DA4946D.5020403@suse.cz> <1302633088.4801.48.camel@lade.trondhjem.org> <4DA49B49.1020005@suse.cz> <4DA49D3A.7090800@netapp.com> <4DA49F7F.8060005@suse.cz>
In-Reply-To: <4DA49F7F.8060005@suse.cz>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/12/2011 02:52 PM, Jiri Slaby wrote:
> On 04/12/2011 08:43 PM, Bryan Schumaker wrote:
>> On 04/12/2011 02:34 PM, Jiri Slaby wrote:
>>> On 04/12/2011 08:31 PM, Trond Myklebust wrote:
>>>>> Yes, it fixes the problem. But it waits 15s before it times out. This is
>>>>> inacceptable for automounted NFS dirs.
>>>>
>>>> I'm still confused as to why you are hitting it at all. In the normal
>>>> autonegotiation case, the client should be trying to use AUTH_SYS first
>>>> and then trying rpcsec_gss if and only if that fails.
>>>>
>>>> Are you really exporting a filesystem using AUTH_NULL as the only
>>>> supported flavour?
>>>
>>> I don't know, I connect to a nfs server which is not maintained by me.
>>> It looks like that. How can I find out?
>>
>> If you're not using gss for anything, you could try rmmod-ing rpcsec_gss_krb5 (and other rpcsec_gss_* modules).
> 
> I don't have NFS in modules. It's all built-in. And this one is
> unconditionally selected because of CONFIG_NFS_V4.

Does this patch help?

- Bryan

We should attempt an AUTH_NULL style mount before
trying gss flavors.  This should prevent a hang if
gss modules are loaded but the userspace program
isn't running.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9bf41ea..4e3c16b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2218,8 +2218,8 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS + 2];
 
 	flav_array[0] = RPC_AUTH_UNIX;
-	len = gss_mech_list_pseudoflavors(&flav_array[1]);
-	flav_array[1+len] = RPC_AUTH_NULL;
+	flav_array[1] = RPC_AUTH_NULL;
+	len = gss_mech_list_pseudoflavors(&flav_array[2]);
 	len += 2;
 
 	for (i = 0; i < len; i++) {


> 
> regards,

