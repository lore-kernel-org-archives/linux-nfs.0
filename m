Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41196 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933121Ab2C2Ogn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 10:36:43 -0400
Message-ID: <4F747368.3040509@parallels.com>
Date: Thu, 29 Mar 2012 18:36:24 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] Lockd: pass network namespace to creation and destruction
 routines
References: <20120329142209.20506.43224.stgit@localhost6.localdomain6>
In-Reply-To: <20120329142209.20506.43224.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch has a flaw. Thus will be v2.
Sorry.

-- 
Best regards,
Stanislav Kinsbursky
