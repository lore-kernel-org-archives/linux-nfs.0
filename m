Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:18285 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030Ab3BRP0g convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 10:26:36 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Kernels 3.7 and newer break rpc.gssd -n
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <505003638.18320.1361175792539.JavaMail.root@opinsys.fi>
Date: Mon, 18 Feb 2013 10:26:29 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D2E173C5-6EEE-4394-A84D-8AABDC5C1726@oracle.com>
References: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi> <1117889154.119108.1360851840169.JavaMail.root@opinsys.fi> <CED6E6AF-B551-4099-89CE-861E5F46D31A@oracle.com> <654867786.10283.1360929631448.JavaMail.root@opinsys.fi> <74874B5C-CDDE-4F77-B69D-FC40FF5DD933@oracle.com> <505003638.18320.1361175792539.JavaMail.root@opinsys.fi>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>,
        =?iso-8859-1?Q?Tuomas_R=E4s=E4nen?= <tuomasjjrasanen@opinsys.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 18, 2013, at 3:23 AM, Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

>>> Yes. With commit 05f4c350 + the compilation fix, the problem occurs, but
>>> without
>>> 05f4c350, the parent (6f2ea7f) works as expected, requesting for service
>>> <null>.
> 
>>>> When the mount operation fails, is it the first time this client attempts
>>>> to
>>>> mount a share on server.example.org, or does the client already have
>>>> mounts
>>>> of server.example.org, possibly using other security flavors?
> 
>>> Yes, the problem occurs on the very first mount attempt.
>> 
>> Thanks for confirming.  Did you try updating nfs-utils on your NFS client to
>> 1.2.8-rc1 or later (specifically to replace rpc.gssd)?
> 
> Yes, gssd from nfs-utils 1.2.8-rc3 behaves the same way and fails when service 
> name is not null.

Thanks for confirming.  My KDC is now back online so I will try to reproduce this today.


> The code in gssd that checks for the service name seems to be the same if I
> understand the code correctly.
> 
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=utils/gssd/gssd_proc.c;h=c17ab3bf914526f433fb6c76ace1daa63c10d921;hb=HEAD#l985
> 
> ---------------------------------------------------------------------------------
>        if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
>                                service == NULL)) {
>                /* Tell krb5 gss which credentials cache to use */
>                for (dirname = ccachesearch; *dirname != NULL; dirname++) {
>                        err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
>                        if (err == -EKEYEXPIRED)
>                                downcall_err = -EKEYEXPIRED;
>                        else if (!err)
>                                create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
>                                                             AUTHTYPE_KRB5);
>                        if (create_resp == 0)
>                                break;
>                }
>        }
> ---------------------------------------------------------------------------------
> 
> Veli-Matti
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




