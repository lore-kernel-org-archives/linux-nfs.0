Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761831AbdADTX7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 14:23:59 -0500
Subject: Re: NFS: SECINFO: security flavor 390003 is not supported
To: Dave Jones <davej@codemonkey.org.uk>, bfields@redhat.com,
        jlayton@poochiereds.net, Linux Kernel <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
References: <20170104190327.v3wbpcbqtfa5jy7d@codemonkey.org.uk>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <0ad14385-401a-9ec7-9b0e-711da9fe1f59@RedHat.com>
Date: Wed, 4 Jan 2017 14:23:58 -0500
MIME-Version: 1.0
In-Reply-To: <20170104190327.v3wbpcbqtfa5jy7d@codemonkey.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/04/2017 02:03 PM, Dave Jones wrote:
> Since upgrading to 4.10-rc2, my nfs server has started printing these..
> 
> [  161.668635] NFS: SECINFO: security flavor 390003 is not supported
> [  161.668655] NFS: SECINFO: security flavor 390004 is not supported
> [  161.668670] NFS: SECINFO: security flavor 390005 is not supported
> 
> Client is debian's 4.8 kernel with default mount options, so sec=sys
> 
> What should I be doing to suppress these ? What causes them ?
The auth_rpcgss or rpcsec_gss_krb5 kernel modules not being loaded??

steved.

> 
> 	Dave
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
