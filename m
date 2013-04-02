Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875Ab3DBSI6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 14:08:58 -0400
Subject: RE: [PATCH 2/3] Avoid reverse resolution for server name
From: Simo Sorce <simo@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286FB37F@SACEXCMBX04-PRD.hq.netapp.com>
References: <1364924947-16985-1-git-send-email-simo@redhat.com>
	 <1364924947-16985-3-git-send-email-simo@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9286FB37F@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 14:08:56 -0400
Message-ID: <1364926136.2660.1270.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 17:58 +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Simo Sorce
> > Sent: Tuesday, April 02, 2013 1:49 PM
> > To: Linux NFS Mailing list
> > Subject: [PATCH 2/3] Avoid reverse resolution for server name
> > 
> > A NFS client should be able to work properly even if the DNS Reverse record
> > for the server is not set. There is no excuse to forcefully prevent that from
> > working when it can.
> 
> Note that rpc.statd has the same limitation.
> 
> > This patch adds a new -N option that takes an 'on' or 'off' argument and
> > controls whether forced PTR resolution is avoided (on) or performed (off)
> 
> '-N' already has a very different meaning on rpc.mountd and rpc.nfsd. It might therefore be better to choose a different name to avoid confusion.
> Also, why do a single option with an 'on/off' argument instead of just choosing 2 options ?
>  
Well Jeff seemed to suggest that way, I do not have any preference, can
you please give me 2 letters to use ?

Meanwhile I'll check rpc.statd as well.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

