Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-by2nam01on0042.outbound.protection.outlook.com ([104.47.34.42]:31387
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751737AbdBATIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Feb 2017 14:08:51 -0500
Date: Wed, 1 Feb 2017 11:07:40 -0800
From: Felix Manlunas <felix.manlunas@cavium.com>
To: Russell King <rmk+kernel@armlinux.org.uk>
CC: <linux-mips@linux-mips.org>, <linux-nfs@vger.kernel.org>,
        <linux-scsi@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        <target-devel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Subject: Re: [PATCH 4.10-rc3 11/13] net: liquidio: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Message-ID: <20170201190740.GA10128@felix.cavium.com>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
 <E1cYdxX-0000X5-Hz@rmk-PC.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <E1cYdxX-0000X5-Hz@rmk-PC.armlinux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Russell King <rmk+kernel@armlinux.org.uk> wrote on Tue [2017-Jan-31 19:19:19 +0000]:
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:30: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:30: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:30: error: type defaults to 'int' in declaration of 'MODULE_AUTHOR'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:30: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:31: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:31: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:31: error: type defaults to 'int' in declaration of 'MODULE_DESCRIPTION'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:31: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:32: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:32: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:32: error: type defaults to 'int' in declaration of 'MODULE_LICENSE'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:32: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:33: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:33: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:33: error: type defaults to 'int' in declaration of 'MODULE_VERSION'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:33: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:36: error: expected ')' before 'int'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:37: error: expected ')' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:325: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:325: error: type defaults to 'int' in declaration of 'MODULE_DEVICE_TABLE'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:325: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3250: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3250: error: type defaults to 'int' in declaration of 'module_init'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3250: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3251: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3251: error: type defaults to 'int' in declaration of 'module_exit'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3251: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_main.c:36: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:36: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:36: error: type defaults to 'int' in declaration of 'MODULE_AUTHOR'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:36: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:37: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:37: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:37: error: type defaults to 'int' in declaration of 'MODULE_DESCRIPTION'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:37: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:38: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:38: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:38: error: type defaults to 'int' in declaration of 'MODULE_LICENSE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:38: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:39: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:39: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:39: error: type defaults to 'int' in declaration of 'MODULE_VERSION'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:39: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:40: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:40: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:40: error: type defaults to 'int' in declaration of 'MODULE_FIRMWARE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:40: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:41: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:41: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:41: error: type defaults to 'int' in declaration of 'MODULE_FIRMWARE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:41: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:42: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:42: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:42: error: type defaults to 'int' in declaration of 'MODULE_FIRMWARE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:42: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:43: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:43: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:43: error: type defaults to 'int' in declaration of 'MODULE_FIRMWARE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:43: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:46: error: expected ')' before 'int'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:48: error: expected ')' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:53: error: expected ')' before 'int'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:54: error: expected ')' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:57: error: expected ')' before 'sizeof'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:58: error: expected ')' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:498: warning: data definitionhas no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:498: error: type defaults to 'int' in declaration of 'MODULE_DEVICE_TABLE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:498: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_main.c: In function 'octeon_recv_vf_drv_notice':
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4393: error: implicit declaration of function 'try_module_get'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4400: error: implicit declaration of function 'module_put'
> drivers/net/ethernet/cavium/liquidio/lio_main.c: At top level:
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4670: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4670: error: type defaults to 'int' in declaration of 'module_init'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4670: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4671: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4671: error: type defaults to 'int' in declaration of 'module_exit'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4671: warning: parameter names (without types) in function declaration
> 
> Add linux/module.h to both these files.
> 
> drivers/net/ethernet/cavium/liquidio/octeon_console.c:40:31: error: expected ')' before 'int'
> drivers/net/ethernet/cavium/liquidio/octeon_console.c:42:4: error: expected ')' before string constant
> 
> Add linux/moduleparam.h to this file.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Acked-by: Felix Manlunas <felix.manlunas@cavium.com>

Thank you.
