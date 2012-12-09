Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54734 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932796Ab2LIJmw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Dec 2012 04:42:52 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so1017458eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 09 Dec 2012 01:42:51 -0800 (PST)
Message-ID: <50C45D17.5090000@tonian.com>
Date: Sun, 09 Dec 2012 11:42:47 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Marc Eshel <eshel@us.ibm.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: notify_deviceid_type4
References: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@us.ibm.com>
In-Reply-To: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-12-01 07:54, Marc Eshel wrote:
> The spec defines notify_deviceid_type4 as:
> 
> 20.12.1.  ARGUMENT
>    /*
>     * Device notification types.
>     */
>    enum notify_deviceid_type4 {
>            NOTIFY_DEVICEID4_CHANGE = 1,
>            NOTIFY_DEVICEID4_DELETE = 2
>    };
> 
> 
> but the Linux code in nfs4.h has, is that going to be fixed?
> 
> enum pnfs_notify_deviceid_type4 {
>         NOTIFY_DEVICEID4_CHANGE = 1 << 1,
>         NOTIFY_DEVICEID4_DELETE = 1 << 2,
> };

notify_deviceid_type4 specifies bit numbers same as notify_type4
It seems to me like the definition in nfs4.h is correct.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
