Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbbIOOKd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2015 10:10:33 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 57499AB0
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2015 14:10:32 +0000 (UTC)
Received: from [10.10.55.163] (vpn-55-163.rdu2.redhat.com [10.10.55.163])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t8FEAU6M003864
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2015 10:10:31 -0400
Date: Tue, 15 Sep 2015 10:10:21 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: NFSv2,3 tcp_retries2 exhausted -> TCP_CLOSED
Message-ID: <alpine.OSX.2.19.9992.1509150959120.71803@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If tcp_retries2 is exhausted the transport's socket is transitioned to
TCP_CLOSED without sending FIN,RST.  That's perfectly fine behavior until
you have a middle-box that silently drops the re-connection's SYNs because
it keeps an established state around until torn down by a FIN or RST.

NFSv4 won't usually make it to tcp_retries2 since it sets
RPC_CLNT_CREATE_DISCRTRY to tear the socket down after a minor timeout,
thus avoiding this particular problem with this particularly stupid
middle-box.

Can anyone tell me if there is a reason not to set RPC_CLNT_CREATE_DISCRTRY
for NFSv3, or make it configurable?

Ben
