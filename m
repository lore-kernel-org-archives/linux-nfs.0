Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-co1nam03on0075.outbound.protection.outlook.com ([104.47.40.75]:18896
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751652AbdAaTcT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jan 2017 14:32:19 -0500
From: Bart Van Assche <Bart.VanAssche@sandisk.com>
To: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rmk+kernel@armlinux.org.uk" <rmk+kernel@armlinux.org.uk>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
CC: "davem@davemloft.net" <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "nab@linux-iscsi.org" <nab@linux-iscsi.org>
Subject: Re: [PATCH 4.10-rc3 09/13] iscsi: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Date: Tue, 31 Jan 2017 19:32:10 +0000
Message-ID: <1485891116.3113.2.camel@sandisk.com>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
         <E1cYdxN-0000Wr-AS@rmk-PC.armlinux.org.uk>
In-Reply-To: <E1cYdxN-0000Wr-AS@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-01-31 at 19:19 +0000, Russell King wrote:
> drivers/target/iscsi/iscsi_target_login.c:1135:7: error: implicit declara=
tion of function 'try_module_get' [-Werror=3Dimplicit-function-declaration]
>=20
> Add linux/module.h to iscsi_target_login.c.
>=20
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> ---
>  drivers/target/iscsi/iscsi_target_login.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/target/iscsi/iscsi_target_login.c b/drivers/target/i=
scsi/iscsi_target_login.c
> index 450f51deb2a2..eab274d17b5c 100644
> --- a/drivers/target/iscsi/iscsi_target_login.c
> +++ b/drivers/target/iscsi/iscsi_target_login.c
> @@ -17,6 +17,7 @@
>   ***********************************************************************=
*******/
> =20
>  #include <crypto/hash.h>
> +#include <linux/module.h>
>  #include <linux/string.h>
>  #include <linux/kthread.h>
>  #include <linux/idr.h>

Reviewed-by: Bart Van Assche <bart.vanassche@sandisk.com>=
