Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61783 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756756Ab3DBSWA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 14:22:00 -0400
Subject: RE: [PATCH 2/3] Avoid reverse resolution for server name
From: Simo Sorce <simo@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286FB37F@SACEXCMBX04-PRD.hq.netapp.com>
References: <1364924947-16985-1-git-send-email-simo@redhat.com>
	 <1364924947-16985-3-git-send-email-simo@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9286FB37F@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 14:21:58 -0400
Message-ID: <1364926918.2660.1273.camel@willson.li.ssimo.org>
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

I checked rpc.statd with a quick "git grep getnameinfo", and as far as I
can see PTR lookups are done only if the 'name' is actually an IP
address, but skipped if not. So I think rpc.statd is ok.

I see rpc.statd uses getaddrinfo with hints set to AI_NUMERICHOST, if
that's preferred over using inet_pton I can change my patches to do the
same.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

