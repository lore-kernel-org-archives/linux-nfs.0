Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:64741 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757895Ab3DBR6D convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2013 13:58:03 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH 2/3] Avoid reverse resolution for server name
Date: Tue, 2 Apr 2013 17:58:01 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286FB37F@SACEXCMBX04-PRD.hq.netapp.com>
References: <1364924947-16985-1-git-send-email-simo@redhat.com>
 <1364924947-16985-3-git-send-email-simo@redhat.com>
In-Reply-To: <1364924947-16985-3-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Simo Sorce
> Sent: Tuesday, April 02, 2013 1:49 PM
> To: Linux NFS Mailing list
> Subject: [PATCH 2/3] Avoid reverse resolution for server name
> 
> A NFS client should be able to work properly even if the DNS Reverse record
> for the server is not set. There is no excuse to forcefully prevent that from
> working when it can.

Note that rpc.statd has the same limitation.

> This patch adds a new -N option that takes an 'on' or 'off' argument and
> controls whether forced PTR resolution is avoided (on) or performed (off)

'-N' already has a very different meaning on rpc.mountd and rpc.nfsd. It might therefore be better to choose a different name to avoid confusion.
Also, why do a single option with an 'on/off' argument instead of just choosing 2 options ?
 
 Trond
