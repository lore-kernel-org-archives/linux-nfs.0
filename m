Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27851 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757434Ab3J1XAC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 19:00:02 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>
CC: "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: RE: [PATCH 1/2] SUNRPC: gss_alloc_msg - choose _either_ a v0
 message or a v1 message
Date: Mon, 28 Oct 2013 22:59:45 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9534E866F@SACEXCMBX04-PRD.hq.netapp.com>
References: <1383001027-62282-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1383001027-62282-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Myklebust, Trond
> Sent: Monday, October 28, 2013 6:57 PM
> To: linux-nfs@vger.kernel.org; Bruce Fields
> Cc: stable@vger.kernel.org
> Subject: [PATCH 1/2] SUNRPC: gss_alloc_msg - choose _either_ a v0 message
> or a v1 message
> 
> Add the missing 'break' to ensure that we don't corrupt a legacy 'v0' type
> message by appending the 'v1'.
> 
> Cc: Bruce Fields <bfields@fieldses.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---

I did not intend to send this to stable@vger.kernel .org before it has hit upstream...

Apologies,
   Trond
