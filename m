Return-Path: linux-nfs-owner@vger.kernel.org
Received: from violet.fr.zoreil.com ([92.243.8.30]:53344 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab2FWGpE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jun 2012 02:45:04 -0400
Date: Sat, 23 Jun 2012 08:13:53 +0200
From: Francois Romieu <romieu@fr.zoreil.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bernard Pidoux <bernard.pidoux@upmc.fr>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org
Subject: Re: rpc_pipefs kernel panic kernel 3.4.3
Message-ID: <20120623061353.GA18625@electric-eye.fr.zoreil.com>
References: <F77FADB4-0415-4945-AC03-CEE36F2FEB08@upmc.fr> <4FE4DB31.4000601@free.fr> <4FE4F7FA.4000604@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FE4F7FA.4000604@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(redirected from l-k, see http://marc.info/?l=linux-kernel&m=134040598419594&w=2)

Bernard Pidoux <bernard.pidoux@free.fr> :
[rpc_pipefs_event panic with 3.4.4 at boot mount, 3.3.8 is fine]

Should Bernard try a git bisect ?

-- 
Ueimor
