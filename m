Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:54096 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396AbaFXOfU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2014 10:35:20 -0400
MIME-Version: 1.0
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
Date: Tue, 24 Jun 2014 17:35:19 +0300
Message-ID: <CAJZOPZ+ix6tPDHXbVrSnVzofHSbzqOoyTBvzkEo-GJpOYOaPFA@mail.gmail.com>
Subject: Re: [PATCH v1 00/13] NFS/RDMA patches for 3.17
From: Or Gerlitz <or.gerlitz@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 24, 2014 at 1:39 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> The main purpose of this series is to address more connection drop
> recovery issues by fixing FRMR re-use to make it less likely the
> client will drop the connection due to a memory operation error.
>
> Some other clean-ups and fixes are present as well.


>From quick looking, patches 1,2 and 5 of series and maybe more have
very good match for 3.16-rc (fix kernel crashes etc), I don't think
they need to wait for 3.17
