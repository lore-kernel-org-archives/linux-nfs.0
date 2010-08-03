Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:39603
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757131Ab0HCQ1Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 12:27:16 -0400
Date: Tue, 3 Aug 2010 18:27:08 +0200
From: Michael Guntsche <mike@it-loops.com>
To: linux-nfs@vger.kernel.org
Subject: Re: Kerberos auth Problem with nfs3/4
Message-ID: <20100803162707.GA9004@gibson.comsick.at>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi again,


Some more information from the logs when trying to mount the export

Aug  3 18:24:28 gibson rpc.gssd: in authgss_create_default()
Aug  3 18:24:28 gibson rpc.gssd: in authgss_create()
Aug  3 18:24:28 gibson rpc.gssd: authgss_create: name is 0x9f852e8
Aug  3 18:24:28 gibson rpc.gssd: authgss_create: gd->name is 0x9f80df8
Aug  3 18:24:28 gibson rpc.gssd: in authgss_refresh()
Aug  3 18:24:28 gibson rpc.gssd: in authgss_marshal()
Aug  3 18:24:28 gibson rpc.gssd: xdr_rpc_gss_cred: encode success (v 1,
proc 1, seq 0, svc 1, ctx (nil):0)
Aug  3 18:24:28 gibson rpc.gssd: xdr_rpc_gss_init_args: encode success
(token 0x9f884f0:595)
Aug  3 18:24:28 gibson rpc.svcgssd: libnfsidmap: using (default) domain:
comsick.at
Aug  3 18:24:28 gibson rpc.svcgssd: libnfsidmap: loaded plugin
/usr/lib/libnfsidmap/nsswitch.so for method nsswitch
Aug  3 18:24:28 gibson rpc.gssd: in authgss_validate()
Aug  3 18:24:28 gibson rpc.gssd: xdr_rpc_gss_init_res decode success
(ctx 0x9f87f80:4, maj 0, min 0, win 128, token 0x9f89dc8:114)
Aug  3 18:24:28 gibson rpc.gssd: authgss_create_default: freeing name
0x9f852e8
Aug  3 18:24:28 gibson rpc.gssd: in authgss_get_private_data()
Aug  3 18:24:28 gibson rpc.gssd: in authgss_free_private_data()
Aug  3 18:24:28 gibson rpc.gssd: in authgss_destroy()
Aug  3 18:24:28 gibson rpc.gssd: in authgss_destroy_context()
Aug  3 18:24:28 gibson rpc.gssd: authgss_destroy: freeing name 0x9f80df8

And then it just steps and the steps repeat after a timeout.

Kind regards,
Michael
