Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45380 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdBAFe0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2017 00:34:26 -0500
From: Kalle Valo <kvalo@codeaurora.org>
To: Russell King <rmk+kernel@armlinux.org.uk>
Cc: linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jiri Slaby <jirislaby@gmail.com>,
        Nick Kossifidis <mickflemm@gmail.com>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH 4.10-rc3 12/13] net: ath5k: fix build errors when linux/phy*.h is removed from net/dsa.h
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
        <E1cYdxc-0000XC-N6@rmk-PC.armlinux.org.uk>
Date: Wed, 01 Feb 2017 07:34:19 +0200
In-Reply-To: <E1cYdxc-0000XC-N6@rmk-PC.armlinux.org.uk> (Russell King's
        message of "Tue, 31 Jan 2017 19:19:24 +0000")
Message-ID: <87r33ibhk4.fsf@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Russell King <rmk+kernel@armlinux.org.uk> writes:

> Fix these errors reported by the 0-day builder by replacing the
> linux/export.h include with linux/module.h.
>
> In file included from include/linux/platform_device.h:14:0,
>                  from drivers/net/wireless/ath/ath5k/ahb.c:20:
> include/linux/device.h:1463:1: warning: data definition has no type or storage class
>  module_init(__driver##_init); \
>  ^
> include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
>   module_driver(__platform_driver, platform_driver_register, \
>   ^~~~~~~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
>  module_platform_driver(ath_ahb_driver);
>  ^~~~~~~~~~~~~~~~~~~~~~
> include/linux/device.h:1463:1: error: type defaults to 'int' in declaration of 'module_init' [-Werror=implicit-int]
>  module_init(__driver##_init); \
>  ^
> include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
>   module_driver(__platform_driver, platform_driver_register, \
>   ^~~~~~~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
>  module_platform_driver(ath_ahb_driver);
>  ^~~~~~~~~~~~~~~~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:1: warning: parameter names (without types) in function declaration
> In file included from include/linux/platform_device.h:14:0,
>                  from drivers/net/wireless/ath/ath5k/ahb.c:20:
> include/linux/device.h:1468:1: warning: data definition has no type or storage class
>  module_exit(__driver##_exit);
>  ^
> include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
>   module_driver(__platform_driver, platform_driver_register, \
>   ^~~~~~~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
>  module_platform_driver(ath_ahb_driver);
>  ^~~~~~~~~~~~~~~~~~~~~~
> include/linux/device.h:1468:1: error: type defaults to 'int' in declaration of 'module_exit' [-Werror=implicit-int]
>  module_exit(__driver##_exit);
>  ^
> include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
>   module_driver(__platform_driver, platform_driver_register, \
>   ^~~~~~~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
>  module_platform_driver(ath_ahb_driver);
>  ^~~~~~~~~~~~~~~~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:1: warning: parameter names (without types) in function declaration
> In file included from include/linux/platform_device.h:14:0,
>                  from drivers/net/wireless/ath/ath5k/ahb.c:20:
> drivers/net/wireless/ath/ath5k/ahb.c:233:24: warning: 'ath_ahb_driver_exit' defined but not used [-Wunused-function]
>  module_platform_driver(ath_ahb_driver);
>                         ^
> include/linux/device.h:1464:20: note: in definition of macro 'module_driver'
>  static void __exit __driver##_exit(void) \
>                     ^~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
>  module_platform_driver(ath_ahb_driver);
>  ^~~~~~~~~~~~~~~~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:24: warning: 'ath_ahb_driver_init' defined but not used [-Wunused-function]
>  module_platform_driver(ath_ahb_driver);
>                         ^
> include/linux/device.h:1459:19: note: in definition of macro 'module_driver'
>  static int __init __driver##_init(void) \
>                    ^~~~~~~~
> drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
>  module_platform_driver(ath_ahb_driver);
>  ^~~~~~~~~~~~~~~~~~~~~~
>
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Looks good to me:

Acked-by: Kalle Valo <kvalo@codeaurora.org>

I assume Dave will take this so I'll drop the patch from my queue.

-- 
Kalle Valo
